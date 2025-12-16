"""
HTTP client for communicating with Spring Boot backend.
"""
import httpx
from typing import Optional, Dict, Any, List
import os

# Spring Boot backend URL
BACKEND_URL = os.getenv("SPRING_BOOT_URL", "http://localhost:8085")
API_BASE = f"{BACKEND_URL}/api"


class BackendClient:
    """Client for making requests to Spring Boot backend."""

    def __init__(self, auth_token: str):
        """
        Initialize backend client with auth token.

        Args:
            auth_token: JWT token to forward to Spring Boot
        """
        self.auth_token = auth_token
        self.headers = {
            "Authorization": f"Bearer {auth_token}",
            "Content-Type": "application/json"
        }
        self.client = httpx.Client(timeout=30.0)

    def __del__(self):
        """Close the HTTP client."""
        self.client.close()

    # Transaction endpoints
    def get_transactions(self, limit: Optional[int] = None, type: Optional[str] = None) -> List[Dict]:
        """Get user's transactions."""
        params = {}
        if limit:
            params["limit"] = limit
        if type:
            params["type"] = type

        response = self.client.get(
            f"{API_BASE}/transactions",
            headers=self.headers,
            params=params
        )
        response.raise_for_status()
        return response.json()

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
        date: Optional[str] = None,
        location: Optional[str] = None,
        recurring: bool = False,
        recurrence_frequency: Optional[str] = None
    ) -> Dict:
        """Create a new transaction."""
        data = {
            "amount": abs(amount),  # Spring Boot handles sign based on type
            "description": description,
            "categoryId": category_id,
            "type": type.upper(),
            "recurring": recurring
        }

        if date:
            data["date"] = date
        if location:
            data["location"] = location
        if recurring and recurrence_frequency:
            data["recurrenceFrequency"] = recurrence_frequency

        response = self.client.post(
            f"{API_BASE}/transactions",
            headers=self.headers,
            json=data
        )
        response.raise_for_status()
        return response.json()

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
        params = {}
        if type:
            params["type"] = type

        response = self.client.get(
            f"{API_BASE}/categories",
            headers=self.headers,
            params=params
        )
        response.raise_for_status()
        return response.json()

    def create_category(self, name: str, type: str) -> Dict:
        """Create a new category."""
        data = {
            "name": name,
            "type": type.upper()
        }

        response = self.client.post(
            f"{API_BASE}/categories",
            headers=self.headers,
            json=data
        )
        response.raise_for_status()
        return response.json()

    # Dashboard/Analytics endpoints
    def get_dashboard_summary(self) -> Dict:
        """Get dashboard summary (balance, income, expenses)."""
        response = self.client.get(
            f"{API_BASE}/transactions/balance",
            headers=self.headers
        )
        response.raise_for_status()
        return response.json()

    def get_monthly_summary(self, month: Optional[int] = None, year: Optional[int] = None) -> Dict:
        """Get monthly income/expense summary."""
        params = {}
        if month:
            params["month"] = month
        if year:
            params["year"] = year

        response = self.client.get(
            f"{API_BASE}/transactions/monthly-summary",
            headers=self.headers,
            params=params
        )
        response.raise_for_status()
        return response.json()

    def get_spending_by_category(self) -> List[Dict]:
        """Get spending grouped by category."""
        response = self.client.get(
            f"{API_BASE}/transactions/spending-by-category",
            headers=self.headers
        )
        response.raise_for_status()
        return response.json()
