"""
LangChain tools that interact with Spring Boot backend.
"""
from langchain.tools import tool
from typing import Optional, Literal
import json
import logging
from pydantic import BaseModel, Field
from backend_client import BackendClient

# Configure logging
logger = logging.getLogger(__name__)


# Pydantic models for tool inputs (ensures type safety)
class ListTransactionsInput(BaseModel):
    """Input schema for listing recent transactions."""
    limit: int = Field(default=10, ge=1, le=100, description="Number of transactions to retrieve (1-100)")
    transaction_type: str = Field(default="", description='Filter by "INCOME" or "EXPENSE", or empty for all')


class TransactionDetailsInput(BaseModel):
    """Input schema for getting transaction details."""
    transaction_id: int = Field(description="The transaction ID number")


class AddTransactionInput(BaseModel):
    """Input schema for adding a new transaction."""
    description: str = Field(description="What the transaction is for")
    amount: float = Field(gt=0, description="Transaction amount in MAD (must be positive)")
    category_name: str = Field(description="Category name (e.g., 'Food', 'Salary')")
    transaction_type: Literal["INCOME", "EXPENSE"] = Field(description="Must be exactly 'INCOME' or 'EXPENSE'")
    transaction_date: str = Field(default="", description="Date in YYYY-MM-DD format, or empty for today")
    location: str = Field(default="", description="Location where transaction occurred")


class UpdateTransactionInput(BaseModel):
    """Input schema for updating a transaction."""
    transaction_id: int = Field(description="The transaction ID to update")
    description: str = Field(default="", description="New description (empty to keep unchanged)")
    amount: float = Field(default=0, ge=0, description="New amount (0 to keep unchanged)")
    category_name: str = Field(default="", description="New category (empty to keep unchanged)")
    location: str = Field(default="", description="New location (empty to keep unchanged)")


class DeleteTransactionInput(BaseModel):
    """Input schema for deleting a transaction."""
    transaction_id: int = Field(description="The transaction ID to delete")


def create_transaction_tools(backend_client: BackendClient):
    """
    Create transaction management tools using Spring Boot API.

    Args:
        backend_client: Authenticated BackendClient instance

    Returns:
        List of LangChain Tool objects
    """

    @tool(args_schema=ListTransactionsInput)
    def list_recent_transactions(limit: int = 10, transaction_type: str = "") -> str:
        """Show the user's most recent income and expense transactions."""
        logger.info(f"🔧 TOOL: list_recent_transactions(limit={limit}, transaction_type={transaction_type})")

        # Convert transaction_type to proper format or None
        type_filter = None
        if transaction_type and transaction_type.upper() in ["INCOME", "EXPENSE"]:
            type_filter = transaction_type.upper()

        try:
            transactions = backend_client.get_transactions(limit=limit, type=type_filter)

            if not transactions:
                return "No transactions found."

            output = []
            for t in transactions:
                date = t.get('transactionDate', t.get('date', 'N/A'))
                desc = t.get('description', 'No description')
                amount = t.get('amount', 0)
                txn_type = t.get('type', 'N/A')
                category = t.get('categoryName', 'N/A')

                output.append(
                    f"#{t['id']} [{date}] {desc} - {amount} MAD ({txn_type}) - Category: {category}"
                )

            logger.info(f"✅ Listed {len(transactions)} transactions")
            return "\n".join(output)

        except Exception as e:
            logger.error(f"❌ Error listing transactions: {str(e)}")
            return f"Error listing transactions: {str(e)}"

    @tool(args_schema=TransactionDetailsInput)
    def get_transaction_details(transaction_id: int) -> str:
        """Get full details about a specific transaction by its ID number."""
        logger.info(f"🔧 TOOL: get_transaction_details(id={transaction_id})")

        try:
            transaction = backend_client.get_transaction(transaction_id)
            logger.info(f"✅ Retrieved transaction #{transaction_id}")
            return json.dumps(transaction, indent=2)
        except Exception as e:
            logger.error(f"❌ Error fetching transaction #{transaction_id}: {str(e)}")
            return f"Error fetching transaction #{transaction_id}: {str(e)}"

    @tool(args_schema=AddTransactionInput)
    def add_transaction(
        description: str,
        amount: float,
        category_name: str,
        transaction_type: str,
        transaction_date: str = "",
        location: str = ""
    ) -> str:
        """Add a new income or expense transaction to the user's account."""
        logger.info(f"🔧 TOOL: add_transaction(desc='{description}', amount={amount}, category='{category_name}', type={transaction_type}, date={transaction_date})")

        # Normalize transaction type (Pydantic already validates it's INCOME or EXPENSE)
        transaction_type = transaction_type.upper()

        # Handle date
        date_to_use = transaction_date if transaction_date and transaction_date != "" else None

        # Handle location
        location_to_use = location if location and location != "" else None

        try:
            # First, get categories to find the category ID
            categories = backend_client.get_categories(type=transaction_type)

            # Find matching category (case-insensitive)
            category_id = None
            for cat in categories:
                if cat['name'].lower() == category_name.lower():
                    category_id = cat['id']
                    break

            # If category not found, create it
            if category_id is None:
                try:
                    new_category = backend_client.create_category(category_name, transaction_type)
                    category_id = new_category['id']
                except Exception:
                    return f"Error: Category '{category_name}' not found and could not be created."

            # Create the transaction
            transaction = backend_client.create_transaction(
                amount=abs(amount),
                description=description,
                category_id=category_id,
                type=transaction_type,
                transaction_date=date_to_use,
                location=location_to_use
            )

            date_info = f" on {transaction.get('transactionDate', 'today')}" if date_to_use else ""
            logger.info(f"✅ Transaction created: ID={transaction['id']}, amount={amount} MAD")
            return f"✅ Successfully added {transaction_type.lower()}: '{description}' for {abs(amount)} MAD{date_info} (Category: {category_name}, ID: #{transaction['id']})"

        except Exception as e:
            logger.error(f"❌ Failed to add transaction: {str(e)}")
            return f"Error adding transaction: {str(e)}"

    @tool(args_schema=UpdateTransactionInput)
    def update_transaction(
        transaction_id: int,
        description: str = "",
        amount: float = 0,
        category_name: str = "",
        location: str = ""
    ) -> str:
        """Update one or more fields of an existing transaction."""
        logger.info(f"🔧 TOOL: update_transaction(id={transaction_id}, desc={description}, amount={amount})")

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

    @tool(args_schema=DeleteTransactionInput)
    def delete_transaction(transaction_id: int) -> str:
        """Permanently delete a transaction from the user's account."""
        logger.info(f"🔧 TOOL: delete_transaction(id={transaction_id})")

        try:
            backend_client.delete_transaction(transaction_id)
            logger.info(f"✅ Deleted transaction #{transaction_id}")
            return f"✅ Successfully deleted transaction #{transaction_id}"
        except Exception as e:
            logger.error(f"❌ Error deleting transaction: {str(e)}")
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
        """Get the user's current financial balance with total income and expenses.

        Returns:
            Current balance, total income, and total expenses in MAD
        """
        logger.info(f"🔧 TOOL: get_balance_summary()")
        try:
            summary = backend_client.get_dashboard_summary()
            balance = summary.get('currentBalance', 0)
            income = summary.get('totalIncome', 0)
            expenses = summary.get('totalExpense', 0)
            logger.info(f"✅ Balance: {balance} MAD (Income: {income}, Expenses: {expenses})")

            return f"Current Balance: {balance} MAD\nTotal Income: {income} MAD\nTotal Expenses: {expenses} MAD"
        except Exception as e:
            logger.error(f"❌ Error fetching balance: {str(e)}")
            return f"Error fetching balance summary: {str(e)}"

    @tool
    def get_monthly_summary(year: int = 2025) -> str:
        """Get income and expense breakdown for each month of the year.

        Args:
            year: Year to get summary for (defaults to 2025)

        Returns:
            Monthly breakdown showing income and expenses for each month
        """
        logger.info(f"🔧 TOOL: get_monthly_summary(year={year})")
        try:
            summary = backend_client.get_monthly_summary(year)
            logger.info(f"✅ Retrieved monthly summary for {year}")
            return json.dumps(summary, indent=2)
        except Exception as e:
            logger.error(f"❌ Error fetching monthly summary: {str(e)}")
            return f"Error fetching monthly summary: {str(e)}"

    @tool
    def get_spending_by_category() -> str:
        """Analyze spending patterns by showing how much was spent in each category.

        Returns:
            Breakdown of expenses by category (Food, Transport, Bills, etc.)
        """
        logger.info(f"🔧 TOOL: get_spending_by_category()")
        try:
            data = backend_client.get_spending_by_category()
            total = data.get('totalSpending', 0)
            categories = data.get('categories', [])
            logger.info(f"✅ Spending analysis: {total} MAD across {len(categories)} categories")
            return json.dumps(data, indent=2)
        except Exception as e:
            logger.error(f"❌ Error fetching spending data: {str(e)}")
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
