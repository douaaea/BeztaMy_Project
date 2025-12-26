from app.services.rag_service import rag_service
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

if __name__ == "__main__":
    query = "How do I create a budget?"
    print(f"\nTesting RAG Retrieval for query: '{query}'\n" + "-"*50)
    
    try:
        # Initialize (loads vector store)
        rag_service.initialize()
        
        # Retrieve
        results = rag_service.retrieve_knowledge(query, k=3)
        
        if results:
            for i, doc in enumerate(results, 1):
                print(f"\nResult #{i}:")
                print(f"Source: {doc.metadata.get('source')}")
                print(f"Intent: {doc.metadata.get('intent')}")
                print(f"Content Preview: {doc.page_content[:200]}...")
        else:
            print("No results found.")
            
    except Exception as e:
        logger.error(f"Test failed: {e}")
