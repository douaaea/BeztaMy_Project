# SimpleRAG - Financial Assistant

A RAG (Retrieval-Augmented Generation) based financial assistant for the BeztaMy project, specifically tailored for the Moroccan context. It combines a LangChain/LangGraph agent with a Spring Boot backend for transaction management and a ChromaDB vector store for financial knowledge retrieval.

## 📂 Architecture

The project is organized efficiently to separate concerns:

```
simpleRag/
├── app/                        # Application Core
│   ├── services/               # Logic Services
│   │   ├── intent_config.py    # Intent mapping logic
│   │   └── rag_service.py      # RAG implementation (Embeddings, Retrieval)
│   ├── auth.py                 # Authentication helpers
│   ├── backend_client.py       # HTTP Client for Spring Boot API
│   ├── config.py               # Configuration settings
│   └── tools.py                # LangChain tools definitions
├── data/                       # Knowledge Base (Markdown files)
├── evaluation_ragas/           # Quality Evaluation
│   ├── eval_rag_quality.py     # RAGAS evaluation script
│   └── sample_dataset.json     # Test cases
├── main.py                     # FastAPI Application Entry Point
├── index_data.py               # Script to index documents
├── test_rag.py                 # Script to verify retrieval
└── .env.example                # Environment variables template
```

## 🚀 Setup & Installation

1.  **Prerequisites**:

    - Python 3.10+
    - [Ollama](https://ollama.com/) (for embeddings)
    - Groq API Key (for the LLM)

2.  **Install Dependencies**:

    ```bash
    pip install -r requirements.txt
    # Or manually modules like: fastapi, uvicorn, langchain, langchain-groq, langchain-chroma, etc.
    ```

    _(Note: Ensure you have `uv` or `pip` set up)_

3.  **Environment Variables**:
    Copy `.env.example` to `.env` and fill in your keys:

    ```bash
    cp .env.example .env
    ```

4.  **Backend Connection**:
    Ensure the Spring Boot backend is running (default: `http://localhost:8085`).

## 🧠 Knowledge Base

- **Embeddings**: We use `embeddinggemma:latest` via **Ollama**.
  ```bash
  ollama serve
  ollama pull embeddinggemma:latest
  ```
- **Vector Store**: [ChromaDB](https://www.trychroma.com/) (Persisted in `chroma_db_dir`).
- **Indexing**: To load markdown files from `data/` into the database:
  ```bash
  python3 index_data.py
  ```

## 🏃‍♂️ Running the Server

Start the FastAPI server:

```bash
uv run uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

The API will be available at `http://localhost:8000`.

## 🧪 Testing & Evaluation

- **Quick Retrieval Test**:
  ```bash
  python3 test_rag.py
  ```
- **Quality Evaluation (RAGAS)**:
  Evaluates Faithfulness, Relevance, Recall, and Precision.

  ```bash
  python3 evaluation_ragas/eval_rag_quality.py
  ```

  **Evaluation Summary:**

  | Metric                | Q1   | Q2   | Q3   | Q4   | Q5   | Q6   |
  | :-------------------- | :--- | :--- | :--- | :--- | :--- | :--- |
  | **Faithfulness**      | 1.00 | 1.00 | 1.00 | 1.00 | 1.00 | 1.00 |
  | **Relevance**         | 0.78 | 0.97 | 0.85 | 0.88 | 1.00 | 0.90 |
  | **Context Recall**    | 1.00 | 1.00 | 1.00 | 1.00 | 1.00 | 1.00 |
  | **Context Precision** | 1.00 | 1.00 | 1.00 | 1.00 | 0.70 | 1.00 |

## 🛠️ Tech Stack

- **Framework**: FastAPI
- **RAG/LLM**: LangChain, LangGraph, Groq (Llama 3)
- **Embeddings**: Ollama (Gemma)
- **Vector DB**: Chroma
- **Evaluation**: Ragas
