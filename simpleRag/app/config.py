import os

# RAG Configuration
RAG_INDEX_PATH = "./chroma_db_dir"
OLLAMA_BASE_URL = "http://localhost:11434"
DOCS_DIR = "./data"

# LLM Configuration
GROQ_MODEL = os.getenv("GROQ_MODEL", "meta-llama/llama-3.1-8b-instant")
GROQ_API_KEY = os.getenv("GROQ_API_KEY") # Ensure this is set in your environment
