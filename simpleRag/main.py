import os
import traceback
import logging
from typing import Optional
from contextlib import asynccontextmanager
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from langchain_ollama import OllamaEmbeddings
from langchain_chroma import Chroma
from langchain_groq import ChatGroq
from langchain.tools import tool
from langchain.agents import create_agent
from langgraph.checkpoint.memory import MemorySaver
from dotenv import load_dotenv

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

load_dotenv()



# Global variables for the RAG components
vector_store = None
agent_executor = None
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
    global vector_store, agent_executor, memory

    # Initialize embeddings
    embeddings = OllamaEmbeddings(model="embeddinggemma:latest")

    # Initialize vector store
    vector_store = Chroma(
        embedding_function=embeddings,
        persist_directory="chroma_db_dir"
    )

    # Create retriever
    retriever = vector_store.as_retriever()

    # Build a retriever tool for the agent to call when it needs context
    @tool
    def retrieve_context(query: str):
        """Search knowledge base for facts to answer questions."""
        retrieved_docs = retriever.invoke(query)
        serialized = "\n\n".join(
            (f"Source: {doc.metadata}\nContent: {doc.page_content}")
            for doc in retrieved_docs
        )
        return serialized

    # Initialize LLM with tool calling support
    llm = ChatGroq(
        model="llama-3.3-70b-versatile",
        api_key=os.getenv("GROQ_API_KEY"),
        temperature=0,  # Lower temperature for more consistent tool calling
        max_retries=3   # Retry failed requests
    )

    # Initialize memory saver for conversation history
    memory = MemorySaver()

    # Create system prompt for the agent
    system_prompt = (
        "You are a helpful assistant that must ground all answers in retrieved "
        "context. Keep responses under three sentences and always end with "
        '"thanks for asking!"'
    )

    # Assemble the agent with memory and system prompt
    agent_executor = create_agent(
        llm,
        tools=[retrieve_context],
        system_prompt=system_prompt,
        checkpointer=memory
    )

    print("RAG system initialized!")
    yield
    print("Shutting down...")

# Initialize FastAPI app
app = FastAPI(title="RAG Chat API", version="1.0.0", lifespan=lifespan)


@app.post("/chat", response_model=ChatResponse)
async def chat(request: ChatRequest):
    """
    Chat endpoint that answers questions using RAG with conversation memory.

    Args:
        request: ChatRequest containing the question and session_id

    Returns:
        ChatResponse with the answer and session_id
    """
    if agent_executor is None:
        raise HTTPException(status_code=503, detail="RAG system not initialized")

    try:
        # Invoke the agent with message history using LangGraph's thread-based checkpointing
        result = agent_executor.invoke(
            {"messages": [("user", request.question)]},
            config={"configurable": {"thread_id": request.session_id}}
        )
        # Extract the answer from the agent's messages
        answer = result["messages"][-1].content
        return ChatResponse(answer=answer, session_id=request.session_id)
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
        "agent_initialized": agent_executor is not None,
        "memory_initialized": memory is not None
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
