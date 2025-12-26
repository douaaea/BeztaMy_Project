def infer_intent_from_filename(doc_name: str) -> str:
    """
    Map filenames to intent categories for better retrieval context.
    
    Args:
        doc_name: The name of the document file (without extension if possible, or handle it)
        
    Returns:
        The intent category string.
    """
    # Remove extension if present
    name = doc_name.replace(".md", "")
    
    mapping = {
        "budgeting_strategies": "budgeting",
        "cash_flow_management": "budgeting",
        "expense_categories_tracking": "spending",
        "financial_health": "general",
        "income_optimization": "income",
        "investment_basics": "investing",
        "smart_spending": "spending",
        "01_budgeting_and_tracking": "budgeting", 
        "02_saving_and_investing": "investing",   
        "03_debt_and_spending": "spending"        
    }
    
    # Try to find a match, default to "general"
    return mapping.get(name, "general")
