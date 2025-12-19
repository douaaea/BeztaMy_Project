"""
HTTP client for communicating with Spring Boot backend.
"""
import httpx
from typing import Optional, Dict, Any, List
import os
import logging
from datetime import date

# Configure logging
logger = logging.getLogger(__name__)

# Spring Boot backend URL
BACKEND_URL = os.getenv("SPRING_BOOT_URL", "http://localhost:8085")
API_BASE = f"{BACKEND_URL}/api"


class BackendClient:
    """Client for making requests to Spring Boot backend."""

    def __init__(self, auth_token: str, user_id: int):
        """
        Initialize backend client with auth token and user ID.

        Args:
            auth_token: JWT token to forward to Spring Boot
            user_id: User ID to include in requests
        """
        self.auth_token = auth_token
        self.user_id = user_id
        self.headers = {
            "Authorization": f"Bearer {auth_token}",
            "Content-Type": "application/json"
        }
        self.client = httpx.Client(timeout=30.0)
        logger.info(f"🔐 BackendClient initialized for userId={user_id}")

    def __del__(self):
        """Close the HTTP client."""
        self.client.close()

    # Transaction endpoints
    def get_transactions(self, limit: Optional[int] = None, type: Optional[str] = None) -> List[Dict]:
        """Get user's transactions."""
        logger.info(f"📋 Getting transactions (userId={self.user_id}, limit={limit}, type={type})")
        params = {"userId": self.user_id}
        if limit:
            params["limit"] = limit
        if type:
            params["type"] = type

        response = self.client.get(
            f"{API_BASE}/transactions",
            headers=self.headers,
            params=params
        )
        logger.info(f"✅ Got {response.status_code} from GET /transactions")
        response.raise_for_status()
        result = response.json()
        logger.info(f"📊 Retrieved {len(result)} transactions")
        return result

    def get_transaction(self, transaction_id: int) -> Dict:
        """Get a specific transaction by ID."""
        response = self.client.get(
            f"{API_BASE}/transactions/{transaction_id}",
            headers=self.headers
        )
        response.raise_for_status()
        return response.json()

    def create_transaction(
        self,
        amount: float,
        description: str,
        category_id: int,
        type: str,
        transaction_date: Optional[str] = None,
        location: Optional[str] = None,
        recurring: bool = False,
        recurrence_frequency: Optional[str] = None
    ) -> Dict:
        """Create a new transaction."""
        logger.info(f"💰 Creating {type} transaction for userId={self.user_id}: {description} - {amount} MAD")

        # transactionDate is required - default to today if not provided
        if not transaction_date:
            transaction_date = date.today().isoformat()
            logger.info(f"📅 No date provided, using today: {transaction_date}")

        data = {
            "amount": abs(amount),  # Spring Boot handles sign based on type
            "description": description,
            "categoryId": category_id,
            "type": type.upper(),
            "transactionDate": transaction_date,  # Required field
            "isRecurring": recurring
        }

        if location:
            data["location"] = location
        if recurring and recurrence_frequency:
            data["frequency"] = recurrence_frequency

        logger.info(f"📦 Transaction data: {data}")
        response = self.client.post(
            f"{API_BASE}/transactions",
            headers=self.headers,
            params={"userId": self.user_id},
            json=data
        )
        logger.info(f"✅ Got {response.status_code} from POST /transactions")
        response.raise_for_status()
        result = response.json()
        logger.info(f"✅ Transaction created successfully (ID: {result.get('id')})")
        return result

    def update_transaction(
        self,
        transaction_id: int,
        amount: Optional[float] = None,
        description: Optional[str] = None,
        category_id: Optional[int] = None,
        date: Optional[str] = None,
        location: Optional[str] = None
    ) -> Dict:
        """Update an existing transaction."""
        data = {}
        if amount is not None:
            data["amount"] = abs(amount)
        if description:
            data["description"] = description
        if category_id:
            data["categoryId"] = category_id
        if date:
            data["date"] = date
        if location:
            data["location"] = location

        response = self.client.put(
            f"{API_BASE}/transactions/{transaction_id}",
            headers=self.headers,
            json=data
        )
        response.raise_for_status()
        return response.json()

    def delete_transaction(self, transaction_id: int) -> Dict:
        """Delete a transaction."""
        response = self.client.delete(
            f"{API_BASE}/transactions/{transaction_id}",
            headers=self.headers
        )
        response.raise_for_status()
        return {"message": "Transaction deleted successfully", "id": transaction_id}

    # Category endpoints
    def get_categories(self, type: Optional[str] = None) -> List[Dict]:
        """Get available categories."""
        logger.info(f"🏷️  Getting categories for userId={self.user_id} (type={type})")
        params = {"userId": self.user_id}
        if type:
            params["type"] = type

        response = self.client.get(
            f"{API_BASE}/categories",
            headers=self.headers,
            params=params
        )
        logger.info(f"✅ Got {response.status_code} from GET /categories")
        response.raise_for_status()
        result = response.json()
        logger.info(f"📋 Retrieved {len(result)} categories")
        return result

    def create_category(self, name: str, type: str) -> Dict:
        """Create a new category."""
        logger.info(f"🏷️  Creating category for userId={self.user_id}: {name} ({type})")
        data = {
            "name": name,
            "type": type.upper()
        }

        response = self.client.post(
            f"{API_BASE}/categories",
            headers=self.headers,
            params={"userId": self.user_id},
            json=data
        )
        logger.info(f"✅ Got {response.status_code} from POST /categories")
        response.raise_for_status()
        result = response.json()
        logger.info(f"✅ Category created successfully (ID: {result.get('id')})")
        return result

    # Dashboard/Analytics endpoints
    def get_dashboard_summary(self) -> Dict:
        """Get dashboard summary (balance, income, expenses)."""
        logger.info(f"📊 Getting dashboard summary for userId={self.user_id}")
        response = self.client.get(
            f"{API_BASE}/transactions/dashboard/balance",
            headers=self.headers,
            params={"userId": self.user_id}
        )
        logger.info(f"✅ Got {response.status_code} from GET /transactions/dashboard/balance")
        if response.status_code == 403:
            logger.error(f"❌ 403 Forbidden - Check userId={self.user_id} and auth token")
            logger.error(f"Response body: {response.text}")
        response.raise_for_status()
        result = response.json()
        logger.info(f"📈 Dashboard: balance={result.get('currentBalance')}, income={result.get('totalIncome')}, expenses={result.get('totalExpense')}")
        return result

    def get_monthly_summary(self, year: int) -> List[Dict]:
        """Get monthly income/expense summary for the year."""
        logger.info(f"📅 Getting monthly summary for userId={self.user_id}, year={year}")
        response = self.client.get(
            f"{API_BASE}/transactions/dashboard/monthly-summary",
            headers=self.headers,
            params={"userId": self.user_id, "year": year}
        )
        logger.info(f"✅ Got {response.status_code} from GET /transactions/dashboard/monthly-summary")
        response.raise_for_status()
        result = response.json()
        logger.info(f"📊 Retrieved monthly summary with {len(result)} months")
        return result

    def get_spending_by_category(self) -> Dict:
        """Get spending grouped by category."""
        logger.info(f"📊 Getting spending by category for userId={self.user_id}")
        response = self.client.get(
            f"{API_BASE}/transactions/dashboard/spending-categories",
            headers=self.headers,
            params={"userId": self.user_id}
        )
        logger.info(f"✅ Got {response.status_code} from GET /transactions/dashboard/spending-categories")
        response.raise_for_status()
        result = response.json()
        logger.info(f"📊 Spending data: total={result.get('totalSpending')}, categories={len(result.get('categories', []))}")
        return result
