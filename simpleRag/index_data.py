from app.services.rag_service import rag_service
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

if __name__ == "__main__":
    logger.info("Starting manual indexing...")
    try:
        rag_service.index_documents()
        logger.info("Indexing completed successfully.")
    except Exception as e:
        logger.error(f"Indexing failed: {e}")
