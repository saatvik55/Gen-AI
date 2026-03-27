from fastapi import APIRouter, Depends
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session

from ..database import get_db
from ..schemas import GoogleAuthRequest, Token, UserLogin, UserOut, UserRegister
from ..services import auth_service

router = APIRouter(prefix="/auth", tags=["auth"])

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/login")


@router.post("/register", response_model=UserOut, status_code=201)
def register(data: UserRegister, db: Session = Depends(get_db)):
    return auth_service.register_user(db, data)


@router.post("/login", response_model=Token)
def login(data: UserLogin, db: Session = Depends(get_db)):
    return auth_service.login_user(db, data.identifier, data.password)


@router.post("/google", response_model=Token)
async def google_login(data: GoogleAuthRequest, db: Session = Depends(get_db)):
    return await auth_service.google_auth(db, data.token)


@router.get("/me", response_model=UserOut)
def get_me(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    return auth_service.get_current_user(db, token)
