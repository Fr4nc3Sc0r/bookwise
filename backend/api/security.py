from fastapi import Security, HTTPException, status
from fastapi.security.api_key import APIKeyHeader
from dotenv import load_dotenv
import os

load_dotenv("backend/.env")

API_KEY = os.getenv("API_KEY")
apy_key_header = ApiKeyHeader(name="X-API-key", auto_error=false)

async def verify_api_key(api_key: str = Security(api_key_header)):
    if api_key != API_KEY:
        raise HTTPException(
            status_code = status.HTTP_403_FORBIDDEN,
            detail="API key non funzionante o mancante"
        )
    return api_key