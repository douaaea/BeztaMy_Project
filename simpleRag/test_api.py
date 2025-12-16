"""
Test script for the RAG Chat API with Transaction Management.

Prerequisites:
    1. Spring Boot backend running on http://localhost:8085
    2. Python RAG backend running on http://localhost:8000
    3. A registered user account

Usage:
    1. Update the TEST_USER credentials below
    2. Start both backends
    3. Run: uv run test_api.py
"""
import requests
import json
from typing import Optional

# API endpoints
SPRING_BOOT_URL = "http://localhost:8085"
PYTHON_RAG_URL = "http://localhost:8000"

# Test user credentials - UPDATE THESE WITH YOUR TEST USER
TEST_USER = {
    "email": "test@example.com",
    "password": "password123"
}

# Global auth token
AUTH_TOKEN: Optional[str] = None


def get_auth_token() -> str:
    """Get JWT token from Spring Boot backend."""
    global AUTH_TOKEN

    if AUTH_TOKEN:
        return AUTH_TOKEN

    print("=" * 60)
    print("Getting JWT Token from Spring Boot")
    print("=" * 60)

    try:
        response = requests.post(
            f"{SPRING_BOOT_URL}/api/auth/login",
            json=TEST_USER,
            headers={"Content-Type": "application/json"}
        )

        if response.status_code == 200:
            data = response.json()
            AUTH_TOKEN = data.get("token")
            print(f"✅ Successfully authenticated as: {TEST_USER['email']}")
            print(f"Token: {AUTH_TOKEN[:50]}...\n")
            return AUTH_TOKEN
        else:
            print(f"❌ Login failed: {response.status_code}")
            print(f"Response: {response.text}")
            raise Exception("Authentication failed")

    except requests.exceptions.ConnectionError:
        print("❌ Could not connect to Spring Boot backend")
        print(f"Make sure it's running on {SPRING_BOOT_URL}")
        raise


def send_chat_message(question: str, session_id: str = "test_session") -> dict:
    """Send a message to the chatbot."""
    token = get_auth_token()

    response = requests.post(
        f"{PYTHON_RAG_URL}/chat",
        json={
            "question": question,
            "session_id": session_id
        },
        headers={
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json"
        }
    )

    if response.status_code == 200:
        return response.json()
    else:
        print(f"❌ Error: {response.status_code}")
        print(f"Response: {response.text}")
        raise Exception(f"Chat request failed: {response.status_code}")


def test_health_check():
    """Test the health check endpoint."""
    print("=" * 60)
    print("Testing Health Check")
    print("=" * 60)

    response = requests.get(f"{PYTHON_RAG_URL}/health")
    print(f"Status Code: {response.status_code}")
    print(f"Response: {json.dumps(response.json(), indent=2)}\n")


def test_add_transactions():
    """Test adding transactions through chatbot."""
    print("=" * 60)
    print("Testing Add Transactions")
    print("=" * 60 + "\n")

    test_cases = [
        "Add an expense of 150 MAD for groceries at Marjane",
        "Record an income of 8000 MAD from my salary",
        "Add a 45 MAD expense for lunch at a restaurant",
        "I spent 200 MAD on transportation this week",
    ]

    for i, question in enumerate(test_cases, 1):
        print(f"Test {i}:")
        print(f"Q: {question}")
        try:
            result = send_chat_message(question, "test_add_transactions")
            print(f"A: {result['answer']}\n")
        except Exception as e:
            print(f"❌ Failed: {e}\n")


def test_list_transactions():
    """Test listing transactions."""
    print("=" * 60)
    print("Testing List Transactions")
    print("=" * 60 + "\n")

    test_cases = [
        "Show me my last 5 transactions",
        "What are my recent expenses?",
        "List my income transactions",
        "Show all transactions from this month",
    ]

    for i, question in enumerate(test_cases, 1):
        print(f"Test {i}:")
        print(f"Q: {question}")
        try:
            result = send_chat_message(question, "test_list_transactions")
            print(f"A: {result['answer']}\n")
        except Exception as e:
            print(f"❌ Failed: {e}\n")


def test_balance_and_analytics():
    """Test balance and analytics queries."""
    print("=" * 60)
    print("Testing Balance & Analytics")
    print("=" * 60 + "\n")

    test_cases = [
        "What's my current balance?",
        "How much did I spend this month?",
        "Show me my spending breakdown by category",
        "What's my total income and expenses?",
        "Give me a monthly summary",
    ]

    for i, question in enumerate(test_cases, 1):
        print(f"Test {i}:")
        print(f"Q: {question}")
        try:
            result = send_chat_message(question, "test_analytics")
            print(f"A: {result['answer']}\n")
        except Exception as e:
            print(f"❌ Failed: {e}\n")


def test_update_delete_transactions():
    """Test updating and deleting transactions."""
    print("=" * 60)
    print("Testing Update & Delete Transactions")
    print("=" * 60 + "\n")

    # First, ask to list transactions to get IDs
    print("Step 1: Getting transaction IDs")
    print("Q: Show me my last 3 transactions with their IDs")
    try:
        result = send_chat_message(
            "Show me my last 3 transactions with their IDs",
            "test_update_delete"
        )
        print(f"A: {result['answer']}\n")
    except Exception as e:
        print(f"❌ Failed: {e}\n")
        return

    # Note: In a real test, you'd parse the IDs from the response
    # For this demo, we'll use placeholder requests

    test_cases = [
        "Update the description of transaction #1 to 'Weekly groceries'",
        "Change the amount of transaction #2 to 100 MAD",
        # "Delete transaction #3",  # Uncomment to test deletion
    ]

    for i, question in enumerate(test_cases, 1):
        print(f"Step {i + 1}:")
        print(f"Q: {question}")
        try:
            result = send_chat_message(question, "test_update_delete")
            print(f"A: {result['answer']}\n")
        except Exception as e:
            print(f"❌ Failed: {e}\n")


def test_financial_advice():
    """Test financial advice from RAG knowledge base."""
    print("=" * 60)
    print("Testing Financial Advice (RAG)")
    print("=" * 60 + "\n")

    test_cases = [
        "What's the 50/30/20 budgeting rule?",
        "How can I save more money?",
        "Give me tips for reducing my expenses",
        "What are some good saving strategies?",
        "How should I budget my income?",
    ]

    for i, question in enumerate(test_cases, 1):
        print(f"Test {i}:")
        print(f"Q: {question}")
        try:
            result = send_chat_message(question, "test_financial_advice")
            print(f"A: {result['answer']}\n")
        except Exception as e:
            print(f"❌ Failed: {e}\n")


def test_mixed_conversation():
    """Test conversation mixing transactions and advice."""
    print("=" * 60)
    print("Testing Mixed Conversation")
    print("=" * 60 + "\n")

    session_id = "test_mixed_conversation"

    conversation = [
        "What's my current balance?",
        "Is that good? Should I be saving more?",
        "Okay, add a savings goal of 2000 MAD for emergency fund",
        "How much am I spending on food?",
        "That seems high. What are some tips to reduce food expenses?",
        "Thanks! Can you add a reminder to track my food spending?",
    ]

    for i, question in enumerate(conversation, 1):
        print(f"Turn {i}:")
        print(f"Q: {question}")
        try:
            result = send_chat_message(question, session_id)
            print(f"A: {result['answer']}\n")
        except Exception as e:
            print(f"❌ Failed: {e}\n")


def test_categories():
    """Test category management."""
    print("=" * 60)
    print("Testing Category Management")
    print("=" * 60 + "\n")

    test_cases = [
        "What categories do I have?",
        "List all expense categories",
        "Create a new category called 'Entertainment' for expenses",
        "Show me my categories again",
    ]

    for i, question in enumerate(test_cases, 1):
        print(f"Test {i}:")
        print(f"Q: {question}")
        try:
            result = send_chat_message(question, "test_categories")
            print(f"A: {result['answer']}\n")
        except Exception as e:
            print(f"❌ Failed: {e}\n")


def test_conversation_memory():
    """Test conversation memory and context."""
    print("=" * 60)
    print("Testing Conversation Memory")
    print("=" * 60 + "\n")

    session_id = "test_memory"

    print("Turn 1:")
    print("Q: Add an expense of 500 MAD for rent")
    result1 = send_chat_message("Add an expense of 500 MAD for rent", session_id)
    print(f"A: {result1['answer']}\n")

    print("Turn 2 (Follow-up):")
    print("Q: Actually, change that amount to 600 MAD")
    result2 = send_chat_message("Actually, change that amount to 600 MAD", session_id)
    print(f"A: {result2['answer']}\n")

    print("Turn 3 (Context check):")
    print("Q: What was the last transaction I added?")
    result3 = send_chat_message("What was the last transaction I added?", session_id)
    print(f"A: {result3['answer']}\n")


def test_error_handling():
    """Test error handling."""
    print("=" * 60)
    print("Testing Error Handling")
    print("=" * 60 + "\n")

    test_cases = [
        ("Invalid transaction ID", "Delete transaction #999999"),
        ("Missing information", "Add a transaction"),
        ("Invalid amount", "Add an expense of -50 MAD for lunch"),
    ]

    for i, (desc, question) in enumerate(test_cases, 1):
        print(f"Test {i} - {desc}:")
        print(f"Q: {question}")
        try:
            result = send_chat_message(question, "test_errors")
            print(f"A: {result['answer']}\n")
        except Exception as e:
            print(f"Expected error: {e}\n")


def main():
    """Run all tests."""
    print("\n")
    print("*" * 60)
    print("*" + " " * 58 + "*")
    print("*" + "  BeztaMy RAG Chatbot - Comprehensive Test Suite  ".center(58) + "*")
    print("*" + " " * 58 + "*")
    print("*" * 60)
    print("\n")

    try:
        # Authentication
        get_auth_token()

        # Health check
        test_health_check()

        # Transaction management tests
        test_add_transactions()
        test_list_transactions()
        test_balance_and_analytics()
        test_categories()

        # Update/Delete tests
        # test_update_delete_transactions()  # Uncomment if you want to test updates/deletes

        # RAG tests
        test_financial_advice()

        # Advanced conversation tests
        test_conversation_memory()
        test_mixed_conversation()

        # Error handling
        # test_error_handling()  # Uncomment to test error cases

        print("\n")
        print("=" * 60)
        print("✅ All tests completed successfully!")
        print("=" * 60)
        print("\n")

    except requests.exceptions.ConnectionError as e:
        print("\n❌ Connection Error:")
        print("Make sure both backends are running:")
        print(f"  - Spring Boot: {SPRING_BOOT_URL}")
        print(f"  - Python RAG: {PYTHON_RAG_URL}")
    except Exception as e:
        print(f"\n❌ Test failed: {e}")
        import traceback
        traceback.print_exc()


if __name__ == "__main__":
    main()
