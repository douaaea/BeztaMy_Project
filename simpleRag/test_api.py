"""
Test script for the RAG Chat API endpoint with conversation memory.

Usage:
    1. Start the server: python main.py
    2. Run this test: python test_api.py
"""
import requests

# API endpoint
BASE_URL = "http://localhost:8000"


def test_health_check():
    """Test the health check endpoint."""
    print("Testing health check endpoint...")
    response = requests.get(f"{BASE_URL}/health")
    print(f"Status Code: {response.status_code}")
    print(f"Response: {response.json()}\n")


def test_conversation_memory():
    """Test conversation memory with follow-up questions."""
    print("=" * 60)
    print("Testing Conversation Memory")
    print("=" * 60 + "\n")

    session_id = "test_session_1"

    # First question
    print("Question 1:")
    payload = {
        "question": "What is the 50/30/20 rule?",
        "session_id": session_id
    }
    response = requests.post(f"{BASE_URL}/chat", json=payload)
    if response.status_code == 200:
        print(f"Q: {payload['question']}")
        print(f"A: {response.json()['answer']}\n")

    # Follow-up question (uses context from first question)
    print("Question 2 (Follow-up):")
    payload = {
        "question": "Can you give me an example of how to apply it?",
        "session_id": session_id
    }
    response = requests.post(f"{BASE_URL}/chat", json=payload)
    if response.status_code == 200:
        print(f"Q: {payload['question']}")
        print(f"A: {response.json()['answer']}\n")

    # Another follow-up
    print("Question 3 (Follow-up):")
    payload = {
        "question": "What percentage was for savings again?",
        "session_id": session_id
    }
    response = requests.post(f"{BASE_URL}/chat", json=payload)
    if response.status_code == 200:
        print(f"Q: {payload['question']}")
        print(f"A: {response.json()['answer']}\n")

    # Check conversation history
    print("Conversation History:")
    response = requests.get(f"{BASE_URL}/chat/history/{session_id}")
    if response.status_code == 200:
        data = response.json()
        print(f"Session: {data['session_id']}")
        print(f"Messages: {data['message_count']}\n")


def test_multiple_sessions():
    """Test multiple independent chat sessions."""
    print("=" * 60)
    print("Testing Multiple Independent Sessions")
    print("=" * 60 + "\n")

    # Session 1 - About budgeting
    print("Session 1 - Budgeting:")
    payload = {
        "question": "Tell me about budgeting",
        "session_id": "session_budgeting"
    }
    response = requests.post(f"{BASE_URL}/chat", json=payload)
    if response.status_code == 200:
        print(f"Q: {payload['question']}")
        print(f"A: {response.json()['answer']}\n")

    # Session 2 - About debt
    print("Session 2 - Debt:")
    payload = {
        "question": "How do I manage debt?",
        "session_id": "session_debt"
    }
    response = requests.post(f"{BASE_URL}/chat", json=payload)
    if response.status_code == 200:
        print(f"Q: {payload['question']}")
        print(f"A: {response.json()['answer']}\n")

    # Follow-up in Session 1 (should remember budgeting context)
    print("Follow-up in Session 1:")
    payload = {
        "question": "What tools did you mention?",
        "session_id": "session_budgeting"
    }
    response = requests.post(f"{BASE_URL}/chat", json=payload)
    if response.status_code == 200:
        print(f"Q: {payload['question']}")
        print(f"A: {response.json()['answer']}\n")


def test_clear_history():
    """Test clearing conversation history."""
    print("=" * 60)
    print("Testing Clear History")
    print("=" * 60 + "\n")

    session_id = "test_clear_session"

    # Create some conversation
    payload = {"question": "What is investing?", "session_id": session_id}
    requests.post(f"{BASE_URL}/chat", json=payload)

    # Check history exists
    response = requests.get(f"{BASE_URL}/chat/history/{session_id}")
    print(f"Before clear: {response.json()['message_count']} messages")

    # Clear history
    response = requests.delete(f"{BASE_URL}/chat/history/{session_id}")
    print(f"Clear response: {response.json()['message']}")

    # Check history is cleared
    response = requests.get(f"{BASE_URL}/chat/history/{session_id}")
    print(f"After clear: {response.json()['message_count']} messages\n")


if __name__ == "__main__":
    print("=" * 60)
    print("RAG Chat API with Memory - Test Script")
    print("=" * 60 + "\n")

    try:
        # Test health check
        test_health_check()

        # Test conversation memory
        test_conversation_memory()

        # Test multiple independent sessions
        test_multiple_sessions()

        # Test clearing history
        test_clear_history()

        print("=" * 60)
        print("All tests completed!")
        print("=" * 60)

    except requests.exceptions.ConnectionError:
        print("Error: Could not connect to the server.")
        print("Make sure the server is running with: python main.py")
    except Exception as e:
        print(f"Error: {e}")