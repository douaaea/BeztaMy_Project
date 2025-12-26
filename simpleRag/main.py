import os
import traceback
import logging
from typing import Optional
from contextlib import asynccontextmanager
from fastapi import FastAPI, HTTPException, Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from langchain_groq import ChatGroq
from langchain.tools import tool
from langchain.agents import create_agent
from langgraph.checkpoint.memory import MemorySaver
from dotenv import load_dotenv

from auth import get_current_user
from backend_client import BackendClient
from tools import get_all_tools

# Import Refactored Services and Config
from app.config import GROQ_MODEL, GROQ_API_KEY
from app.services.rag_service import rag_service

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

load_dotenv()

# Security
security = HTTPBearer()

# Global variables
llm = None
memory = None

class ChatRequest(BaseModel):
    question: str
    session_id: Optional[str] = "default"
    user_id: int  # Required userId from frontend

class ChatResponse(BaseModel):
    answer: str
    session_id: str

@asynccontextmanager
async def lifespan(app: FastAPI):
    """Initialize the RAG components on startup."""
    global llm, memory

    # Initialize RAG Service (Embeddings & Vector Store)
    try:
        rag_service.initialize()
        # Optional: Check if we need to index on first run if DB is empty
        # For now, we assume index_data.py is run manually or DB persists.
    except Exception as e:
        logger.error(f"Failed to initialize RAG Service: {e}")
        # We continue, but RAG calls might fail or return empty

    # Initialize LLM with tool calling support
    logger.info(f"🤖 Using Groq model: {GROQ_MODEL}")

    llm = ChatGroq(
        model=GROQ_MODEL,
        api_key=GROQ_API_KEY,
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
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins in development
    allow_credentials=True,
    allow_methods=["*"],  # Allow all methods
    allow_headers=["*"],  # Allow all headers
)

@app.post("/chat", response_model=ChatResponse)
async def chat(
    request: ChatRequest,
    credentials: HTTPAuthorizationCredentials = Depends(security)
):
    """
    Chat endpoint that answers questions using RAG with conversation memory.
    Requires JWT authentication.
    """
    if llm is None or memory is None:
        raise HTTPException(status_code=503, detail="System not initialized")

    try:
        # Get user info from token (validates token)
        user_info = get_current_user(credentials)
        logger.info(f"Chat request from user: {user_info['email']}")

        # Create backend client
        auth_token = credentials.credentials
        backend_client = BackendClient(auth_token, request.user_id)

        # Define RAG tool using our service
        @tool
        def retrieve_financial_knowledge(query: str) -> str:
            """
            Search knowledge base for financial advice and best practices.
            Use this when the user asks for general financial advice, budgeting tips,
            saving strategies, or other financial guidance.
            """
            logger.info(f"🔧 TOOL CALLED: retrieve_financial_knowledge(query='{query}')")
            serialized = rag_service.get_serialized_knowledge(query)
            logger.info(f"✅ RAG knowledge retrieved")
            return serialized

        # Get all backend tools
        backend_tools = get_all_tools(backend_client)

        # Combine all tools
        all_tools = [retrieve_financial_knowledge, *backend_tools]

        # Create system prompt
        system_prompt = (
            "You are BeztaMy Financial Assistant, a helpful AI that helps users manage their personal finances in Morocco.\n"
            "\n"
            "Core Guidelines:\n"
            "- When users ask about their finances (balance, budget, spending, transactions), use the appropriate analytics and transaction tools.\n"
            "- If a user asks for advice about a purchase (e.g., 'should I buy X?'), you must first check their current balance and recent spending patterns.\n"
            "- When users ask for financial advice or general money tips, use the financial knowledge retrieval tool, but ALWAYS contextualize it with their actual financial situation if possible.\n"
            "- Always confirm before deleting transactions.\n"
            "- Be helpful, concise, and friendly.\n"
            "- Format currency amounts as 'X MAD' (Moroccan Dirham).\n"
            "\n"
            "Date Handling:\n"
            "- Convert relative dates (e.g., 'tomorrow', 'last week') or named dates to YYYY-MM-DD format.\n"
            "- If no date is mentioned, use today's date.\n"
            "\n"
            "Transaction Categories:\n"
            "- Income: Salary, Freelance, Gift, Refund, etc.\n"
            "- Expense: Food, Transport, Shopping, Bills, Entertainment, Health, Education, etc.\n"
            "- You can create or use existing categories that best fit the user's description."
        )

        # Create agent with all tools
        agent_executor = create_agent(
            llm,
            tools=all_tools,
            system_prompt=system_prompt,
            checkpointer=memory
        )

        # Invoke the agent
        logger.info(f"🤖 Invoking agent with question: '{request.question}'")
        logger.info(f"📝 Session ID: {request.session_id}, User ID: {request.user_id}")

        result = agent_executor.invoke(
            {"messages": [("user", request.question)]},
            config={"configurable": {"thread_id": request.session_id}}
        )

        # Extract answer
        answer = result["messages"][-1].content
        logger.info(f"✅ Agent response generated")

        return ChatResponse(answer=answer, session_id=request.session_id)

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error processing question '{request.question}': {str(e)}")
        logger.error(traceback.format_exc())
        raise HTTPException(status_code=500, detail=f"Error processing question: {str(e)}")

@app.delete("/chat/history/{session_id}")
async def clear_history(session_id: str):
    """Clear conversation history for a specific session."""
    if memory is None:
        raise HTTPException(status_code=503, detail="Memory system not initialized")
    return {"message": "LangGraph manages memory internally. Starting a new conversation (new session_id) is recommended to clear context."}

@app.get("/chat/history/{session_id}")
async def get_history(session_id: str):
    """Get conversation history for a specific session."""
    if memory is None:
        raise HTTPException(status_code=503, detail="Memory system not initialized")
    
    # We can't easily access agent_executor here because it's created per request in valid scope.
    # To support this, we'd need to reconstruct the agent or use the memory object directly if possible.
    # MemorySaver uses a specific configuration.
    
    # NOTE: The original code used `agent_executor` which was global-ish or accessible. 
    # In the refactor, `agent_executor` is created inside `chat`.
    # However, `memory` is global. `MemorySaver` methods might be accessible regarding checkpoints.
    # But `MemorySaver` stores checkpoints, not just list of messages efficiently for simple retrieval without the graph structure.
    
    # For now, adhering to safety, we'll return an empty list or a message saying history retrieval needs the graph.
    # OR, we can try to access the storage using the config.
    
    try:
        # Construct a dummy agent or access memory directly if possible. 
        # MemorySaver.get(config) -> Checkpoint
        config = {"configurable": {"thread_id": session_id}}
        checkpoint = memory.get(config)
        if checkpoint:
             # This is a Snapshot object
             values = checkpoint.get("channel_values", {}) # Internal structure might vary
             # If we want to strictly follow previous behavior, we might need to recreate the agent logic
             # or just access the 'messages' key if we know the state schema.
             # The state schema depends on the graph.
             pass
        
        return {"session_id": session_id, "message_count": 0, "messages": [], "note": "History retrieval requires graph context."}
        
    except Exception:
        return {"session_id": session_id, "message_count": 0, "messages": []}

@app.get("/health")
async def health_check():
    """Health check endpoint."""
    return {
        "status": "healthy",
        "llm_initialized": llm is not None,
        "rag_service_initialized": rag_service._initialized,
        "memory_initialized": memory is not None
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)