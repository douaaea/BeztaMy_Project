# RAG Implementation Plan

## Overview
Implement a local RAG (Retrieval-Augmented Generation) system using:
- **Embeddings**: embeddinggemma:latest (via Ollama)
- **Vector Store**: Chroma (persisted to disk)
- **Documents**: Markdown files from `data/` directory
- **Framework**: LangChain

## Prerequisites

### 1. Install Ollama & Pull Model
```bash
# Install Ollama (if not installed)
# macOS: brew install ollama

# Start Ollama service
ollama serve

# Pull embedding model
ollama pull embeddinggemma:latest
```

### 2. Install Python Dependencies
```bash
pip install langchain-ollama langchain-chroma langchain-text-splitters langchain-core
```

### 3. Verify Data Directory
- Confirm markdown files exist in `data/`
- Current files (from git status):
  - budgeting_strategies.md
  - cash_flow_management.md
  - expense_categories_tracking.md
  - financial_health.md
  - income_optimization.md
  - investment_basics.md
  - smart_spending.md

## Implementation Steps

### Step 1: Update Configuration
**File**: `app/config.py` or `settings.py`

Add:
```python
RAG_INDEX_PATH = "./chroma_db"
OLLAMA_BASE_URL = "http://localhost:11434"
DOCS_DIR = "./data"
```

### Step 2: Create Intent Mapping
**File**: `app/services/intent_config.py`

Map filenames to intent categories:
```python
def infer_intent_from_filename(doc_name: str) -> str:
    mapping = {
        "budgeting_strategies": "budgeting",
        "cash_flow_management": "budgeting",
        "expense_categories_tracking": "spending",
        "financial_health": "general",
        "income_optimization": "income",
        "investment_basics": "investing",
        "smart_spending": "spending"
    }
    return mapping.get(doc_name, "general")
```

### Step 3: Implement RAG Service
**File**: `app/services/rag_service.py`

- Use the refactored code with OllamaEmbeddings
- Add error handling for Ollama connection
- Add logging instead of print statements

### Step 4: Test Embedding Generation
Create a simple test script:
```python
from app.services.rag_service import rag_service

# Initialize and create index
rag_service.initialize()

# Test retrieval
result = rag_service.retrieve_knowledge("How do I create a budget?", k=3)
print(result)
```

### Step 5: Integration Testing
- Test with different query intents
- Verify filter functionality
- Check fallback behavior
- Measure retrieval quality

## Potential Issues & Solutions

### Issue 1: Ollama Not Running
**Symptom**: Connection refused errors
**Solution**: Run `ollama serve` in background

### Issue 2: Slow Initial Indexing
**Symptom**: First run takes long time
**Solution**: Normal - embeddinggemma processes all docs. Subsequent runs load from disk.

### Issue 3: Poor Retrieval Quality
**Symptoms**: Irrelevant results
**Solutions**:
- Increase `k` parameter (retrieve more chunks)
- Adjust `chunk_size` and `chunk_overlap`
- Improve document structure/headers
- Try different embedding models

### Issue 4: Stale Index
**Symptom**: New documents not reflected
**Solution**: Delete `chroma_db/` folder to force re-indexing

## Performance Notes

- **Embedding Speed**: embeddinggemma is slower than API-based embeddings but free
- **First Run**: ~30-60 seconds for 7 documents
- **Subsequent Runs**: <1 second (loads from disk)
- **Query Time**: ~100-500ms per query

## Next Steps (Post-Implementation)

1. Add proper logging (replace print statements)
2. Add error handling (try/except blocks)
3. Create evaluation metrics (retrieval accuracy)
4. Consider hybrid search (keyword + semantic)
5. Add document refresh mechanism
6. Implement caching for frequent queries

## Testing Checklist

- [ ] Ollama service running
- [ ] embeddinggemma model pulled
- [ ] All dependencies installed
- [ ] Data directory contains .md files
- [ ] Config settings updated
- [ ] Initial indexing completes
- [ ] Retrieval returns relevant results
- [ ] Intent filtering works
- [ ] Fallback logic triggers correctly
- [ ] Persistence works (restart service, re-query)