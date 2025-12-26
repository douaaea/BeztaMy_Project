#!/usr/bin/env python3
"""
RAGAS Evaluation Script for Manage Money RAG System

Evaluates RAG response quality using RAGAS metrics:
- Faithfulness
- Answer Relevance
- Context Recall
- Context Precision

Usage:
    python backend/evaluation/eval_rag_quality.py
"""

import asyncio
import csv
import json
import math
import os
import sys
import warnings
from datetime import datetime
from pathlib import Path
from typing import Any, Dict, List

from dotenv import load_dotenv

# Add backend directory to path to allow imports from app
sys.path.append(str(Path(__file__).parent.parent))

# Load environment variables
load_dotenv(Path(__file__).parent.parent / ".env")

# Note: We use httpx to call the RAG endpoint directly instead of importing the graph

# Suppress warnings
warnings.filterwarnings("ignore", category=DeprecationWarning)

# Conditional imports for RAGAS
try:
    from datasets import Dataset
    from ragas import evaluate
    from ragas.metrics import (
        AnswerRelevancy,
        ContextPrecision,
        ContextRecall,
        Faithfulness,
    )
    from ragas.llms import LangchainLLMWrapper
    from langchain_openai import ChatOpenAI, OpenAIEmbeddings
    from langchain_groq import ChatGroq
    from tqdm.auto import tqdm
    RAGAS_AVAILABLE = True
except ImportError as e:
    RAGAS_AVAILABLE = False
    print(f"RAGAS dependencies not found. Error: {e}")
    print("Please install them to run evaluations.")
    # We might not want to exit if it's just main app import, but the script calls sys.exit(1) currently.
    # If this module is imported by app/main.py, exiting here will crash the app.
    # The user is running the APP, not the eval script directly (CMD is uvicorn).
    # If the app imports this module, this top-level code runs.
    # We should probably NOT exit if just imported, OR only raise if running as script?
    # But RAGAS_AVAILABLE flag suggests conditional logic.
    # However, existing code had sys.exit(1).
    # If we are in the app, we probably don't want to crash just because dev deps are missing?
    # But wait, ragas is in 'dependencies' now, not dev-dependencies.
    # So it SHOULD be there. If it fails, something is broken.
    # So crashing is probably "correct" for "fail fast" if it's supposed to be there.
    # Let's just print the error for now to debug.
    sys.exit(1)

def _is_nan(value: Any) -> bool:
    return isinstance(value, float) and math.isnan(value)

class RAGEvaluator:
    def __init__(self, test_dataset_path: str = None):
        if test_dataset_path is None:
            test_dataset_path = Path(__file__).parent / "sample_dataset.json"
        
        self.test_dataset_path = Path(test_dataset_path)
        self.results_dir = Path(__file__).parent / "results"
        self.results_dir.mkdir(exist_ok=True)
        
        self.test_cases = self._load_test_dataset()
        
        # Configure RAGAS LLM and Embeddings
        provider = os.getenv("LLM_PROVIDER_EVAL", "GROQ").upper()
        
        if provider == "OPENAI":
            llm_model = os.getenv("EVAL_LLM_MODEL", "gpt-4o-mini")
            llm_api_key = os.getenv("EVAL_LLM_BINDING_API_KEY", os.getenv("OPENAI_API_KEY"))
            base_llm = ChatOpenAI(
                model=llm_model,
                api_key=llm_api_key
            )
        else:
            # Default to GROQ
            llm_model = os.getenv("EVAL_LLM_MODEL", "llama-3.3-70b-versatile")
            llm_api_key = os.getenv("EVAL_LLM_BINDING_API_KEY", os.getenv("GROQ_API_KEY"))
            
            base_llm = ChatGroq(
                model=llm_model,
                api_key=llm_api_key,
                temperature=0
            )
        
        # Wrap LLM with LangchainLLMWrapper and enable bypass_n mode
        # This is critical for Groq and other providers that don't support n>1
        try:
            self.eval_llm = LangchainLLMWrapper(
                langchain_llm=base_llm,
                bypass_n=True
            )
            print("Successfully configured bypass_n mode for LLM wrapper")
        except Exception as e:
            print(f"Warning: Could not configure LangchainLLMWrapper with bypass_n: {e}")
            self.eval_llm = base_llm

        # Embeddings Configuration
        embedding_provider = os.getenv("EVAL_EMBEDDING_PROVIDER", "OPENAI").upper()
        
        if embedding_provider == "OLLAMA":
            # Use local Ollama embeddings (matches the app's setup)
            try:
                from langchain_ollama import OllamaEmbeddings
                embedding_model = os.getenv("EVAL_EMBEDDING_MODEL", "embeddinggemma:latest")
                base_url = os.getenv("OLLAMA_BASE_URL", "http://localhost:11434")
                self.eval_embeddings = OllamaEmbeddings(
                    model=embedding_model,
                    base_url=base_url
                )
                print(f"Using Ollama Embeddings for Eval: {embedding_model}")
            except ImportError:
                print("Error: langchain-ollama not installed. Install it to use Ollama embeddings.")
                sys.exit(1)
        else:
            # Default to OpenAI
            embedding_model = os.getenv("EVAL_EMBEDDING_MODEL", "text-embedding-3-small")
            embedding_api_key = os.getenv("EVAL_EMBEDDING_BINDING_API_KEY", os.getenv("OPENAI_API_KEY"))
            
            self.eval_embeddings = OpenAIEmbeddings(
                model=embedding_model,
                api_key=embedding_api_key
            )

    def _load_test_dataset(self) -> List[Dict[str, str]]:
        if not self.test_dataset_path.exists():
            raise FileNotFoundError(f"Test dataset not found: {self.test_dataset_path}")
        with open(self.test_dataset_path) as f:
            data = json.load(f)
        return data.get("test_cases", [])

    async def generate_rag_response(self, question: str) -> Dict[str, Any]:
        """
        Generate response using direct RAG endpoint (bypasses agent).
        """
        import httpx
        
        try:
            # Call the direct RAG endpoint
            async with httpx.AsyncClient() as client:
                response = await client.post(
                    "http://localhost:8000/rag/retrieve",
                    json={
                        "query": question,
                        "k": 5
                    },
                    timeout=30.0
                )
                response.raise_for_status()
                data = response.json()
            
            contexts = data.get("contexts", [])
            
            # For RAGAS, we need an "answer" - we'll use a simple LLM call
            # to generate an answer based on the retrieved contexts
            from langchain_core.prompts import ChatPromptTemplate
            
            prompt = ChatPromptTemplate.from_messages([
                ("system", "You are a financial advisor. Answer the question based ONLY on the provided context. If the context doesn't contain the answer, say 'I don't have enough information.'"),
                ("user", "Context:\n{context}\n\nQuestion: {question}\n\nAnswer:")
            ])
            
            # Use the evaluation LLM to generate answer
            context_str = "\n\n".join(contexts) if contexts else "No context available."
            messages = prompt.format_messages(context=context_str, question=question)
            
            # Get answer from LLM
            response = await self.eval_llm.langchain_llm.ainvoke(messages)
            answer = response.content if hasattr(response, 'content') else str(response)
            
            # Debug logging
            print(f"DEBUG: Question: {question[:30]}...")
            print(f"DEBUG: Answer: {answer[:30]}...")
            print(f"DEBUG: Contexts found: {len(contexts)}")
            
            return {
                "answer": str(answer),
                "contexts": contexts
            }
            
        except Exception as e:
            print(f"Error calling RAG endpoint: {e}")
            import traceback
            traceback.print_exc()
            return {"answer": "Error", "contexts": []}

    async def evaluate_single_case(self, idx: int, test_case: Dict[str, str]) -> Dict[str, Any]:
        question = test_case["question"]
        ground_truth = test_case["ground_truth"]
        
        print(f"Evaluating {idx}: {question[:50]}...")
        
        # 1. Generate Response
        rag_response = await self.generate_rag_response(question)
        
        # 2. Prepare RAGAS dataset
        # RAGAS expects lists of strings for contexts
        data = {
            "question": [question],
            "answer": [rag_response["answer"]],
            "contexts": [rag_response["contexts"]], 
            "ground_truth": [ground_truth]
        }
        dataset = Dataset.from_dict(data)
        
        # 3. Evaluate
        try:
            results = evaluate(
                dataset=dataset,
                metrics=[
                    Faithfulness(),
                    AnswerRelevancy(),
                    ContextRecall(),
                    ContextPrecision(),
                ],
                llm=self.eval_llm,
                embeddings=self.eval_embeddings,
                raise_exceptions=True, # Enable exceptions to see why metrics fail
            )
            
            # Extract scores
            df = results.to_pandas()
            # print(f"DEBUG: Available metrics: {df.columns.tolist()}")
            scores = df.iloc[0]
            
            # Get ragas_score from DataFrame safely, or calculate it manually
            if "ragas_score" in scores:
                ragas_score = scores["ragas_score"]
            else:
                # Calculate average of available metrics
                metric_values = [
                    float(scores.get("faithfulness", 0)),
                    float(scores.get("answer_relevancy", 0)),
                    float(scores.get("context_recall", 0)),
                    float(scores.get("context_precision", 0))
                ]
                ragas_score = sum(metric_values) / len(metric_values) if metric_values else 0
            
            return {
                "test_number": idx,
                "question": question,
                "answer": rag_response["answer"],
                "ground_truth": ground_truth,
                "contexts": rag_response["contexts"],
                "metrics": {
                    "faithfulness": float(scores.get("faithfulness", 0)),
                    "answer_relevance": float(scores.get("answer_relevancy", 0)),
                    "context_recall": float(scores.get("context_recall", 0)),
                    "context_precision": float(scores.get("context_precision", 0)),
                },
                "ragas_score": float(ragas_score)
            }
            
        except Exception as e:
            print(f"Error in RAGAS evaluation: {e}")
            import traceback
            traceback.print_exc()
            return {
                "test_number": idx,
                "question": question,
                "error": str(e),
                "metrics": {}
            }

    async def run(self):
        print("Starting evaluation...")
        
        # Limit concurrency to avoid rate limits (Groq/OpenAI)
        # Adjust this value based on your tier (e.g. 3-5 for free tiers)
        sem = asyncio.Semaphore(3)

        async def bound_evaluate(idx, test_case):
            async with sem:
                return await self.evaluate_single_case(idx, test_case)

        tasks = [bound_evaluate(idx, test_case) for idx, test_case in enumerate(self.test_cases, 1)]
        results = await asyncio.gather(*tasks)
        
        # Sort results by test_number to maintain order
        results.sort(key=lambda x: x["test_number"])
        
        self._save_results(results)
        self._print_summary(results)

    def _save_results(self, results: List[Dict[str, Any]]):
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        
        # JSON
        json_path = self.results_dir / f"results_{timestamp}.json"
        with open(json_path, "w") as f:
            json.dump(results, f, indent=2)
            
        # CSV
        csv_path = self.results_dir / f"results_{timestamp}.csv"
        with open(csv_path, "w", newline="") as f:
            writer = csv.writer(f)
            writer.writerow(["ID", "Question", "Faithfulness", "Relevance", "Recall", "Precision"])
            for r in results:
                m = r.get("metrics", {})
                writer.writerow([
                    r["test_number"],
                    r["question"],
                    m.get("faithfulness", 0),
                    m.get("answer_relevance", 0),
                    m.get("context_recall", 0),
                    m.get("context_precision", 0)
                ])
        
        print(f"\nResults saved to {self.results_dir}")

    def _print_summary(self, results: List[Dict[str, Any]]):
        print("\n=== Evaluation Summary ===")
        for r in results:
            m = r.get("metrics", {})
            print(f"Q{r['test_number']}: F={m.get('faithfulness', 0):.2f}, R={m.get('answer_relevance', 0):.2f}, CR={m.get('context_recall', 0):.2f}, CP={m.get('context_precision', 0):.2f}")

if __name__ == "__main__":
    evaluator = RAGEvaluator()
    asyncio.run(evaluator.run())
