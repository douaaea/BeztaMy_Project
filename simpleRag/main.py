import os
import traceback
import logging
from typing import Optional
from contextlib import asynccontextmanager
from fastapi import FastAPI, HTTPException, Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from langchain_ollama import OllamaEmbeddings
from langchain_chroma import Chroma
from langchain_groq import ChatGroq
from langchain.tools import tool
from langchain.agents import create_agent
from langgraph.checkpoint.memory import MemorySaver
from dotenv import load_dotenv

from auth import get_current_user
from backend_client import BackendClient
from tools import get_all_tools

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

load_dotenv()

# Security
security = HTTPBearer()



# Global variables for the RAG components
vector_store = None
llm = None
memory = None


class ChatRequest(BaseModel):
    question: str
    session_id: Optional[str] = "default"


class ChatResponse(BaseModel):
    answer: str
    session_id: str


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Initialize the RAG components on startup."""
    global vector_store, llm, memory

    # Initialize embeddings
    embeddings = OllamaEmbeddings(model="embeddinggemma:latest")

    # Initialize vector store
    vector_store = Chroma(
        embedding_function=embeddings,
        persist_directory="chroma_db_dir"
    )

    # Initialize LLM with tool calling support
    llm = ChatGroq(
        model="llama-3.3-70b-versatile",
        api_key=os.getenv("GROQ_API_KEY"),
        temperature=0,  # Lower temperature for more consistent tool calling
        max_retries=3   # Retry failed requests
    )

    # Initialize memory saver for conversation history
    memory = MemorySaver()

    logger.info("RAG system initialized!")
    yield
    logger.info("Shutting down...")

# Initialize FastAPI app
app = FastAPI(title="RAG Chat API", version="1.0.0", lifespan=lifespan)

# Configure CORS
# In development, allow all origins. In production, specify exact origins.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins in development
    allow_credentials=True,
    allow_methods=["*"],  # Allow all methods (GET, POST, OPTIONS, etc.)
    allow_headers=["*"],  # Allow all headers including Authorization
)


@app.post("/chat", response_model=ChatResponse)
async def chat(
    request: ChatRequest,
    credentials: HTTPAuthorizationCredentials = Depends(security)
):
    """
    Chat endpoint that answers questions using RAG with conversation memory.
    Requires JWT authentication.

    Args:
        request: ChatRequest containing the question and session_id
        credentials: JWT token from Authorization header

    Returns:
        ChatResponse with the answer and session_id
    """
    if llm is None or vector_store is None or memory is None:
        raise HTTPException(status_code=503, detail="RAG system not initialized")

    try:
        # Get user info from token (validates token)
        user_info = get_current_user(credentials)
        logger.info(f"Chat request from user: {user_info['email']}")

        # Create backend client with the auth token
        auth_token = credentials.credentials
        backend_client = BackendClient(auth_token)

        # Create retriever tool for financial knowledge
        retriever = vector_store.as_retriever()

        @tool
        def retrieve_financial_knowledge(query: str) -> str:
            """
            Search knowledge base for financial advice and best practices.
            Use this when the user asks for general financial advice, budgeting tips,
            saving strategies, or other financial guidance.
            """
            retrieved_docs = retriever.invoke(query)
            serialized = "\n\n".join(
                (f"Source: {doc.metadata}\nContent: {doc.page_content}")
                for doc in retrieved_docs
            )
            return serialized

        # Get all backend tools (transactions, categories, analytics)
        backend_tools = get_all_tools(backend_client)

        # Combine all tools
        all_tools = [retrieve_financial_knowledge, *backend_tools]

        # Create system prompt
        system_prompt = (
            "You are BeztaMy Financial Assistant, a helpful AI that helps users manage their personal finances. "
            "You have access to the user's transaction data and can perform actions like adding, updating, or deleting transactions. "
            "You also have access to a knowledge base of financial advice and best practices. "
            "\n\n"
            "Guidelines:\n"
            "- When the user asks about their finances (balance, spending, transactions), use the analytics and transaction tools.\n"
            "- When the user asks for financial advice or general questions, use the financial knowledge retrieval tool.\n"
            "- Always confirm before deleting transactions.\n"
            "- Be helpful, concise, and friendly.\n"
            "- Format currency amounts as 'X MAD' (Moroccan Dirham)."
        )

        # Create agent with all tools
        agent_executor = create_agent(
            llm,
            tools=all_tools,
            system_prompt=system_prompt,
            checkpointer=memory
        )

        # Invoke the agent with message history
        result = agent_executor.invoke(
            {"messages": [("user", request.question)]},
            config={"configurable": {"thread_id": request.session_id}}
        )

        # Extract the answer from the agent's messages
        answer = result["messages"][-1].content

        return ChatResponse(answer=answer, session_id=request.session_id)

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error processing question '{request.question}': {str(e)}")
        logger.error(traceback.format_exc())
        raise HTTPException(status_code=500, detail=f"Error processing question: {str(e)}")


@app.delete("/chat/history/{session_id}")
async def clear_history(session_id: str):
    """
    Clear conversation history for a specific session.

    Args:
        session_id: The session ID to clear

    Returns:
        Success message
    """
    if memory is None:
        raise HTTPException(status_code=503, detail="Memory system not initialized")

    # LangGraph's MemorySaver doesn't have a simple delete method
    # The history is managed internally per thread_id
    return {"message": f"Note: LangGraph manages memory internally. Starting a new conversation will use a fresh thread."}


@app.get("/chat/history/{session_id}")
async def get_history(session_id: str):
    """
    Get conversation history for a specific session.

    Args:
        session_id: The session ID to retrieve

    Returns:
        Conversation history
    """
    if memory is None or agent_executor is None:
        raise HTTPException(status_code=503, detail="Memory system not initialized")

    try:
        # Get the state for the thread
        config = {"configurable": {"thread_id": session_id}}
        state = agent_executor.get_state(config)

        messages = state.values.get("messages", [])
        return {
            "session_id": session_id,
            "message_count": len(messages),
            "messages": [
                {
                    "type": msg.type if hasattr(msg, "type") else "unknown",
                    "content": msg.content if hasattr(msg, "content") else str(msg)
                }
                for msg in messages
            ]
        }
    except Exception as e:
        return {"session_id": session_id, "message_count": 0, "messages": []}


@app.get("/health")
async def health_check():
    """Health check endpoint."""
    return {
        "status": "healthy",
        "llm_initialized": llm is not None,
        "vector_store_initialized": vector_store is not None,
        "memory_initialized": memory is not None
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
