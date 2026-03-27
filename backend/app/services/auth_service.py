import os

import httpx
from fastapi import HTTPException
from sqlalchemy.orm import Session

from ..core.security import (
    create_access_token,
    decode_access_token,
    hash_password,
    verify_password,
)
from ..models import User
from ..schemas import Token, UserRegister


def register_user(db: Session, data: UserRegister) -> User:
    if not data.email and not data.phone:
        raise HTTPException(status_code=400, detail="Email or phone is required")

    if data.email:
        if db.query(User).filter(User.email == data.email).first():
            raise HTTPException(status_code=400, detail="Email already registered")

    if data.phone:
        if db.query(User).filter(User.phone == data.phone).first():
            raise HTTPException(status_code=400, detail="Phone already registered")

    user = User(
        full_name=data.full_name,
        email=data.email,
        phone=data.phone,
        hashed_password=hash_password(data.password),
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return user


def login_user(db: Session, identifier: str, password: str) -> Token:
    user = (
        db.query(User)
        .filter((User.email == identifier) | (User.phone == identifier))
        .first()
    )

    if not user or not user.hashed_password:
        raise HTTPException(status_code=401, detail="Invalid credentials")

    if not verify_password(password, user.hashed_password):
        raise HTTPException(status_code=401, detail="Invalid credentials")

    token = create_access_token({"sub": str(user.id)})
    return Token(access_token=token)


async def google_auth(db: Session, id_token: str) -> Token:
    """Verify a Google ID token and create/fetch the user."""
    google_client_id = os.getenv("GOOGLE_CLIENT_ID", "")

    async with httpx.AsyncClient() as client:
        resp = await client.get(
            f"https://oauth2.googleapis.com/tokeninfo?id_token={id_token}"
        )

    if resp.status_code != 200:
        raise HTTPException(status_code=401, detail="Invalid Google token")

    payload = resp.json()

    # Validate audience if GOOGLE_CLIENT_ID is configured
    if google_client_id and payload.get("aud") != google_client_id:
        raise HTTPException(status_code=401, detail="Google token audience mismatch")

    google_id = payload.get("sub")
    email = payload.get("email")
    full_name = payload.get("name")

    # Find existing user by google_id or email, else create one
    user = db.query(User).filter(User.google_id == google_id).first()
    if not user and email:
        user = db.query(User).filter(User.email == email).first()

    if not user:
        user = User(full_name=full_name, email=email, google_id=google_id)
        db.add(user)
        db.commit()
        db.refresh(user)
    elif not user.google_id:
        user.google_id = google_id
        db.commit()

    token = create_access_token({"sub": str(user.id)})
    return Token(access_token=token)


def get_current_user(db: Session, token: str) -> User:
    payload = decode_access_token(token)
    if not payload:
        raise HTTPException(status_code=401, detail="Invalid or expired token")

    user_id = payload.get("sub")
    user = db.query(User).filter(User.id == int(user_id)).first()
    if not user:
        raise HTTPException(status_code=401, detail="User not found")
    return user
