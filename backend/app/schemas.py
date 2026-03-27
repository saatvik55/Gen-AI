from datetime import datetime
from typing import Optional

from pydantic import BaseModel


# ── Auth Schemas ──────────────────────────────────────────────────────────────

class UserRegister(BaseModel):
    full_name: Optional[str] = None
    email: Optional[str] = None
    phone: Optional[str] = None
    password: str


class UserLogin(BaseModel):
    identifier: str  # email or phone
    password: str


class GoogleAuthRequest(BaseModel):
    token: str  # Google ID token from client


class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"


class UserOut(BaseModel):
    id: int
    full_name: Optional[str] = None
    email: Optional[str] = None
    phone: Optional[str] = None
    is_active: bool
    created_at: datetime

    class Config:
        from_attributes = True


class TopicBase(BaseModel):
    title: str
    notes: Optional[str] = None


class TopicCreate(TopicBase):
    pass


class TopicUpdate(BaseModel):
    title: Optional[str] = None
    notes: Optional[str] = None


class TopicOut(BaseModel):
    id: int
    title: str
    summary: Optional[str] = None
    strength_score: float
    last_reviewed: Optional[datetime] = None

    class Config:
        from_attributes = True

