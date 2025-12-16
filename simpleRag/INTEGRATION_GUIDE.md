# BeztaMy RAG Backend Integration Guide

## Overview

The Python RAG backend has been upgraded to include JWT authentication and transaction management capabilities. The chatbot can now:

- **Authenticate users** using the same JWT tokens as Spring Boot
- **Manage transactions** (create, read, update, delete)
- **Analyze finances** (balance, monthly summaries, spending by category)
- **Manage categories**
- **Provide financial advice** from the knowledge base

## Architecture

```
Flutter Frontend
      ↓ (JWT Token)
Python RAG Backend (FastAPI)
      ├─→ Financial Knowledge (ChromaDB + RAG)
      └─→ Spring Boot Backend (Transaction Management)
                ↓
          PostgreSQL Database
```

## New Files

### 1. `auth.py`
Handles JWT token validation using the same secret as Spring Boot.

```python
# Validates JWT tokens
# Extracts user information from tokens
```

### 2. `backend_client.py`
HTTP client for communicating with Spring Boot backend.

```python
# Makes authenticated requests to Spring Boot
# Handles all transaction, category, and analytics endpoints
```

### 3. `tools.py`
LangChain tools that the agent can use.

**Transaction Tools:**
- `list_recent_transactions` - List user's transactions
- `get_transaction_details` - Get specific transaction
- `add_transaction` - Create new transaction
- `update_transaction` - Update existing transaction
- `delete_transaction` - Delete transaction

**Category Tools:**
- `list_categories` - List available categories
- `create_category` - Create new category

**Analytics Tools:**
- `get_balance_summary` - Get current balance
- `get_monthly_summary` - Get monthly income/expense summary
- `get_spending_by_category` - Get spending breakdown

## Environment Variables

`.env` file configuration:

```bash
GROQ_API_KEY=your_groq_api_key

# Must match Spring Boot's JWT secret
JWT_SECRET=404E635266556A586E3272357538782F413F4428472B4B6250645367566B5970
JWT_ALGORITHM=HS256

# Spring Boot Backend URL
SPRING_BOOT_URL=http://localhost:8085
```

## Installation

1. Install new dependencies:

```bash
cd simpleRag
uv sync
```

This will install:
- `pyjwt` - JWT token handling
- `httpx` - HTTP client for Spring Boot communication

## Testing

### 1. Start Spring Boot Backend

```bash
cd Backend/finance-assistant
mvn spring-boot:run
```

Verify it's running on http://localhost:8085

### 2. Start Python RAG Backend

```bash
cd simpleRag
uv run main.py
```

Verify it's running on http://localhost:8000

### 3. Get a JWT Token

First, login to get a JWT token:

```bash
curl -X POST http://localhost:8085/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "yourpassword"
  }'
```

Save the `token` from the response.

### 4. Test the Chat Endpoint

```bash
curl -X POST http://localhost:8000/chat \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "question": "Show me my recent transactions",
    "session_id": "test_session_1"
  }'
```

### Example Queries

**View Transactions:**
```
"Show me my last 5 transactions"
"What did I spend on food last month?"
"List all my income transactions"
```

**Add Transactions:**
```
"Add an expense of 50 MAD for groceries at Marjane"
"Record income of 5000 MAD from salary"
```

**Update/Delete:**
```
"Update transaction #123 amount to 75 MAD"
"Delete transaction #456"
```

**Analytics:**
```
"What's my current balance?"
"Show me my spending breakdown by category"
"How much did I spend this month?"
```

**Financial Advice:**
```
"How can I save more money?"
"What's the 50/30/20 budgeting rule?"
"Give me tips for reducing expenses"
```

## How It Works

1. **Authentication Flow:**
   - Flutter sends request with JWT token in Authorization header
   - Python backend validates token using same secret as Spring Boot
   - Extracts user email from token

2. **Tool Selection:**
   - Agent receives user question
   - Decides which tools to use based on question type
   - For transaction queries → uses backend tools
   - For financial advice → uses RAG retrieval tool

3. **Tool Execution:**
   - Backend tools make HTTP requests to Spring Boot with JWT token
   - Spring Boot validates token and executes request
   - Returns data to Python backend
   - Agent formats response for user

4. **Response:**
   - Agent combines tool results with conversation context
   - Generates natural language response
   - Maintains conversation history via session_id

## Security Features

✅ **JWT Authentication** - All requests require valid JWT tokens
✅ **Token Forwarding** - User's token is forwarded to Spring Boot
✅ **User Isolation** - Spring Boot ensures users only access their own data
✅ **No Database Duplication** - Single source of truth in Spring Boot
✅ **Secure Communication** - All backend communication uses HTTPS-ready httpx

## Next Steps

### Flutter Integration

Update the Flutter chatbot to:

1. Send Authorization header with JWT token
2. Change endpoint from mock to http://localhost:8000/chat (or your deployed URL)
3. Handle authentication errors (401)

Example Flutter code:

```dart
final token = await getAuthToken(); // Get from your auth provider

final response = await dio.post(
  'http://localhost:8000/chat',
  options: Options(
    headers: {
      'Authorization': 'Bearer $token',
    },
  ),
  data: {
    'question': userQuestion,
    'session_id': sessionId,
  },
);
```

### Deployment

For production deployment:

1. Update `SPRING_BOOT_URL` in .env to production URL
2. Use environment-specific JWT secrets
3. Enable HTTPS for both backends
4. Configure CORS in FastAPI if needed
5. Set up proper logging and monitoring

## Troubleshooting

**401 Unauthorized:**
- Check JWT token is valid and not expired
- Verify JWT_SECRET matches Spring Boot configuration

**500 Internal Server Error:**
- Check Spring Boot backend is running
- Verify `SPRING_BOOT_URL` is correct
- Check Spring Boot logs for database errors

**Tool calling errors:**
- Check Groq API rate limits
- Verify GROQ_API_KEY is valid
- Try using a different model if needed

## Files Modified

- `main.py` - Added authentication and tool integration
- `pyproject.toml` - Added pyjwt and httpx dependencies
- `.env` - Added JWT and Spring Boot URL configuration

## Files Created

- `auth.py` - JWT authentication utilities
- `backend_client.py` - Spring Boot HTTP client
- `tools.py` - LangChain tools for transaction management
- `INTEGRATION_GUIDE.md` - This guide
