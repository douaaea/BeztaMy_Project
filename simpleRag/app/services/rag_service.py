import os
import logging
import glob
from typing import List, Optional
from langchain_ollama import OllamaEmbeddings
from langchain_chroma import Chroma
from langchain_community.document_loaders import UnstructuredMarkdownLoader
from langchain_core.documents import Document

from app.config import RAG_INDEX_PATH, OLLAMA_BASE_URL, DOCS_DIR
from app.services.intent_config import infer_intent_from_filename

logger = logging.getLogger(__name__)

class RagService:
    def __init__(self):
        self.embeddings = None
        self.vector_store = None
        self._initialized = False

    def initialize(self):
        """Initialize the RAG service, loading embeddings and vector store."""
        try:
            logger.info("Initializing RAG Service...")
            
            # Initialize embeddings
            # Ensure ollama is running or handle error? 
            # The plan says "Add error handling for Ollama connection"
            try:
                self.embeddings = OllamaEmbeddings(
                    model="embeddinggemma:latest",
                    base_url=OLLAMA_BASE_URL
                )
            except Exception as e:
                logger.error(f"Failed to initialize OllamaEmbeddings: {e}")
                raise

            # Initialize Vector Store
            self.vector_store = Chroma(
                embedding_function=self.embeddings,
                persist_directory=RAG_INDEX_PATH
            )
            
            # Check if vector store has documents, if not, index them
            # This check is basic (checking if collection is empty or dir exists)
            # For Chroma, we can check if there are any documents in the collection
            # However, getting the count might be the easiest way.
            # If the directory exists but logic to check content is tricky without loading.
            # We'll assume if persist_directory is empty/missing or we force re-index.
            # For now, let's just attempt to load if it seems empty.
            
            # Note: Chroma() loads from disk if persist_directory exists.
            
            self._initialized = True
            logger.info("RAG Service initialized successfully.")
            
            # Auto-index if empty?
            # self.index_documents_if_needed()

        except Exception as e:
            logger.error(f"Error initializing RAG Service: {e}")
            self._initialized = False
            raise

    def index_documents(self):
        """Load and index documents from the data directory."""
        if not self._initialized:
            self.initialize()
            
        logger.info(f"Indexing documents from {DOCS_DIR}...")
        
        if not os.path.exists(DOCS_DIR):
            logger.warning(f"Data directory {DOCS_DIR} does not exist.")
            return

        files = glob.glob(os.path.join(DOCS_DIR, "*.md"))
        if not files:
            logger.warning("No markdown files found to index.")
            return

        documents = []
        for file_path in files:
            try:
                loader = UnstructuredMarkdownLoader(file_path, mode="single")
                docs = loader.load()
                
                # Add metadata (intent)
                filename = os.path.basename(file_path)
                intent = infer_intent_from_filename(filename)
                
                for doc in docs:
                   doc.metadata["source"] = filename
                   doc.metadata["intent"] = intent
                
                documents.extend(docs)
                logger.info(f"Loaded {filename} with intent '{intent}'")
            except Exception as e:
                logger.error(f"Error loading file {file_path}: {e}")

        if documents:
            logger.info(f"Adding {len(documents)} documents to vector store...")
            self.vector_store.add_documents(documents)
            logger.info("Documents added and persisted.")
        else:
            logger.info("No documents to add.")

    def retrieve_knowledge(self, query: str, k: int = 3, filter: Optional[dict] = None) -> List[Document]:
        """
        Retrieve relevant documents for a query.
        
        Args:
            query: The search query.
            k: Number of documents to retrieve.
            filter: Optional metadata filter.
            
        Returns:
            List of retrieved Documents.
        """
        if not self._initialized:
            # Lazy initialization or raise error
            self.initialize()

        logger.info(f"Retrieving knowledge for: '{query}' (k={k}, filter={filter})")
        
        try:
            results = self.vector_store.similarity_search(query, k=k, filter=filter)
            return results
        except Exception as e:
            logger.error(f"Error during retrieval: {e}")
            return []

    def get_serialized_knowledge(self, query: str, k: int = 3) -> str:
        """
        Retrieve knowledge and return it as a serialized string for LLM context.
        """
        docs = self.retrieve_knowledge(query, k=k)
        if not docs:
            return "No relevant financial knowledge found."
            
        serialized = "\n\n".join(
            (f"Source: {doc.metadata.get('source', 'Unknown')}\n"
             f"Intent: {doc.metadata.get('intent', 'General')}\n"
             f"Content: {doc.page_content}")
            for doc in docs
        )
        return serialized

# Global instance
rag_service = RagService()
