"""
JWT Authentication utilities matching Spring Boot configuration.
"""
import jwt
import os
import base64
from datetime import datetime, timedelta
from typing import Optional
from fastapi import HTTPException, Security
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from dotenv import load_dotenv

load_dotenv()

# Must match Spring Boot's JWT secret - loaded from environment
JWT_SECRET_BASE64 = os.getenv("JWT_SECRET")
JWT_ALGORITHM = os.getenv("JWT_ALGORITHM", "HS256")

if not JWT_SECRET_BASE64:
    raise ValueError("JWT_SECRET environment variable must be set")

# Spring Boot Base64-decodes the secret key before using it
# We need to do the same to match Spring Boot's behavior
JWT_SECRET = base64.b64decode(JWT_SECRET_BASE64)

security = HTTPBearer()


def decode_token(token: str) -> dict:
    """
    Decode and validate JWT token.

    Args:
        token: JWT token string

    Returns:
        Decoded token payload containing user info

    Raises:
        HTTPException: If token is invalid or expired
    """
    try:
        payload = jwt.decode(token, JWT_SECRET, algorithms=[JWT_ALGORITHM])
        return payload
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Token has expired")
    except jwt.InvalidTokenError:
        raise HTTPException(status_code=401, detail="Invalid token")


def get_current_user(credentials: HTTPAuthorizationCredentials = Security(security)) -> dict:
    """
    Extract user information from JWT token.

    Args:
        credentials: HTTP Bearer credentials from request header

    Returns:
        User payload from token containing user_id, email, etc.
    """
    token = credentials.credentials
    payload = decode_token(token)

    # Extract user information from token
    # Spring Boot typically stores username (email) in 'sub' claim
    user_info = {
        "email": payload.get("sub"),
        "user_id": payload.get("user_id"),  # If Spring Boot includes this
        # Add other fields as needed
    }

    if not user_info["email"]:
        raise HTTPException(status_code=401, detail="Invalid token payload")

    return user_info


def create_token(user_id: int, email: str, expiration_hours: int = 24) -> str:
    """
    Create a new JWT token (for testing purposes).
    In production, tokens should only be created by Spring Boot.

    Args:
        user_id: User ID
        email: User email
        expiration_hours: Token validity in hours

    Returns:
        Encoded JWT token
    """
    payload = {
        "sub": email,
        "user_id": user_id,
        "iat": datetime.utcnow(),
        "exp": datetime.utcnow() + timedelta(hours=expiration_hours)
    }

    token = jwt.encode(payload, JWT_SECRET, algorithm=JWT_ALGORITHM)
    return token
