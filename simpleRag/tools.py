"""
LangChain tools that interact with Spring Boot backend.
"""
from langchain.tools import tool
from typing import Optional
import json
from backend_client import BackendClient


def create_transaction_tools(backend_client: BackendClient):
    """
    Create transaction management tools using Spring Boot API.

    Args:
        backend_client: Authenticated BackendClient instance

    Returns:
        List of LangChain Tool objects
    """

    @tool
    def list_recent_transactions(limit: int = 10, type: Optional[str] = None) -> str:
        """
        List user's recent transactions.

        Args:
            limit: Maximum number of transactions to return (default: 10)
            type: Filter by type - 'INCOME' or 'EXPENSE' (optional)

        Returns:
            Formatted list of transactions
        """
        try:
            transactions = backend_client.get_transactions(limit=limit, type=type)

            if not transactions:
                return "No transactions found."

            output = []
            for t in transactions:
                date = t.get('date', 'N/A')
                desc = t.get('description', 'No description')
                amount = t.get('amount', 0)
                txn_type = t.get('type', 'N/A')
                category = t.get('categoryName', 'N/A')

                output.append(
                    f"#{t['id']} [{date}] {desc} - {amount} MAD ({txn_type}) - Category: {category}"
                )

            return "\n".join(output)

        except Exception as e:
            return f"Error listing transactions: {str(e)}"

    @tool
    def get_transaction_details(transaction_id: int) -> str:
        """
        Get detailed information about a specific transaction.

        Args:
            transaction_id: The ID of the transaction to retrieve

        Returns:
            Transaction details in JSON format
        """
        try:
            transaction = backend_client.get_transaction(transaction_id)
            return json.dumps(transaction, indent=2)
        except Exception as e:
            return f"Error fetching transaction #{transaction_id}: {str(e)}"

    @tool
    def add_transaction(
        description: str,
        amount: float,
        category_name: str,
        type: str,
        location: Optional[str] = None
    ) -> str:
        """
        Create a new income or expense transaction.

        Args:
            description: Description of the transaction
            amount: Amount (positive number, sign is determined by type)
            category_name: Name of the category (e.g., 'Food', 'Salary')
            type: Transaction type - must be 'INCOME' or 'EXPENSE'
            location: Optional location of the transaction

        Returns:
            Success message with transaction ID
        """
        try:
            # First, get categories to find the category ID
            categories = backend_client.get_categories(type=type)

            # Find matching category (case-insensitive)
            category_id = None
            for cat in categories:
                if cat['name'].lower() == category_name.lower():
                    category_id = cat['id']
                    break

            # If category not found, create it
            if category_id is None:
                try:
                    new_category = backend_client.create_category(category_name, type)
                    category_id = new_category['id']
                except Exception:
                    return f"Error: Category '{category_name}' not found and could not be created."

            # Create the transaction
            transaction = backend_client.create_transaction(
                amount=abs(amount),
                description=description,
                category_id=category_id,
                type=type,
                location=location
            )

            return f"✅ Successfully added {type.lower()}: '{description}' for {abs(amount)} MAD (Category: {category_name}, ID: #{transaction['id']})"

        except Exception as e:
            return f"Error adding transaction: {str(e)}"

    @tool
    def update_transaction(
        transaction_id: int,
        description: Optional[str] = None,
        amount: Optional[float] = None,
        category_name: Optional[str] = None,
        location: Optional[str] = None
    ) -> str:
        """
        Update an existing transaction.

        Args:
            transaction_id: ID of the transaction to update
            description: New description (optional)
            amount: New amount (optional)
            category_name: New category name (optional)
            location: New location (optional)

        Returns:
            Success message with updated fields
        """
        try:
            # Get category ID if category_name is provided
            category_id = None
            if category_name:
                # Get the transaction to know its type
                current_txn = backend_client.get_transaction(transaction_id)
                txn_type = current_txn.get('type')

                categories = backend_client.get_categories(type=txn_type)
                for cat in categories:
                    if cat['name'].lower() == category_name.lower():
                        category_id = cat['id']
                        break

                if category_id is None:
                    return f"Error: Category '{category_name}' not found."

            # Update the transaction
            updated = backend_client.update_transaction(
                transaction_id=transaction_id,
                description=description,
                amount=abs(amount) if amount is not None else None,
                category_id=category_id,
                location=location
            )

            changes = []
            if description:
                changes.append(f"description → '{description}'")
            if amount is not None:
                changes.append(f"amount → {abs(amount)} MAD")
            if category_name:
                changes.append(f"category → '{category_name}'")
            if location:
                changes.append(f"location → '{location}'")

            return f"✅ Updated transaction #{transaction_id}: {', '.join(changes)}"

        except Exception as e:
            return f"Error updating transaction: {str(e)}"

    @tool
    def delete_transaction(transaction_id: int) -> str:
        """
        Delete a transaction permanently.

        Args:
            transaction_id: ID of the transaction to delete

        Returns:
            Success message
        """
        try:
            backend_client.delete_transaction(transaction_id)
            return f"✅ Successfully deleted transaction #{transaction_id}"
        except Exception as e:
            return f"Error deleting transaction: {str(e)}"

    return [
        list_recent_transactions,
        get_transaction_details,
        add_transaction,
        update_transaction,
        delete_transaction
    ]


def create_category_tools(backend_client: BackendClient):
    """
    Create category management tools.

    Args:
        backend_client: Authenticated BackendClient instance

    Returns:
        List of LangChain Tool objects
    """

    @tool
    def list_categories(type: Optional[str] = None) -> str:
        """
        List available categories.

        Args:
            type: Filter by 'INCOME' or 'EXPENSE' (optional)

        Returns:
            Formatted list of categories
        """
        try:
            categories = backend_client.get_categories(type=type)

            if not categories:
                return "No categories found."

            output = []
            for cat in categories:
                output.append(f"#{cat['id']}: {cat['name']} ({cat['type']})")

            return "\n".join(output)

        except Exception as e:
            return f"Error listing categories: {str(e)}"

    @tool
    def create_category(name: str, type: str) -> str:
        """
        Create a new category.

        Args:
            name: Category name
            type: 'INCOME' or 'EXPENSE'

        Returns:
            Success message
        """
        try:
            category = backend_client.create_category(name, type)
            return f"✅ Created category: {category['name']} (ID: #{category['id']}, Type: {category['type']})"
        except Exception as e:
            return f"Error creating category: {str(e)}"

    return [list_categories, create_category]


def create_analytics_tools(backend_client: BackendClient):
    """
    Create analytics and dashboard tools.

    Args:
        backend_client: Authenticated BackendClient instance

    Returns:
        List of LangChain Tool objects
    """

    @tool
    def get_balance_summary() -> str:
        """
        Get current balance summary including total income and expenses.

        Returns:
            Balance summary
        """
        try:
            summary = backend_client.get_dashboard_summary()
            return json.dumps(summary, indent=2)
        except Exception as e:
            return f"Error fetching balance summary: {str(e)}"

    @tool
    def get_monthly_summary(month: Optional[int] = None, year: Optional[int] = None) -> str:
        """
        Get monthly income and expense summary.

        Args:
            month: Month number (1-12, optional)
            year: Year (optional)

        Returns:
            Monthly summary data
        """
        try:
            summary = backend_client.get_monthly_summary(month, year)
            return json.dumps(summary, indent=2)
        except Exception as e:
            return f"Error fetching monthly summary: {str(e)}"

    @tool
    def get_spending_by_category() -> str:
        """
        Get spending breakdown by category.

        Returns:
            Category spending data
        """
        try:
            data = backend_client.get_spending_by_category()
            return json.dumps(data, indent=2)
        except Exception as e:
            return f"Error fetching spending by category: {str(e)}"

    return [get_balance_summary, get_monthly_summary, get_spending_by_category]


def get_all_tools(backend_client: BackendClient):
    """
    Get all available tools for the agent.

    Args:
        backend_client: Authenticated BackendClient instance

    Returns:
        List of all LangChain Tool objects
    """
    return [
        *create_transaction_tools(backend_client),
        *create_category_tools(backend_client),
        *create_analytics_tools(backend_client)
    ]
