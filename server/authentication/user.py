from datetime import timedelta, datetime

from jose import jwt
from passlib.context import CryptContext
from pydantic import BaseModel
from sqlalchemy.orm import Session

from database import models, schemas

ADMIN_HASH = "$2b$12$rGIvzQdn2MfWfMqwVXtFduR6Bs3U4JfZkPIeu97MoEQNilRhYVodK"
# TODO: Change this to your own secret key
SECRET_KEY = "bdb29e9c84fb7123bbd2adbea5f874607809e97cc27c0155e497cc39a409bda8"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30


# Represents a JWT token
class Token(BaseModel):
    access_token: str
    token_type: str


# Data to be encoded into a JWT token
class TokenData(BaseModel):
    username: str | None = None


pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def get_password_hash(password):
    return pwd_context.hash(password)


def check_password(password, hashed_password) -> bool:
    return pwd_context.verify(password, hashed_password)


def get_user(db: Session, username: str) -> models.User | None:
    return db.query(models.User).filter(models.User.username == username).first()


def create_user(db: Session, user: schemas.UserCreate):
    hashed_password = get_password_hash(user.password)
    db_user = models.User(username=user.username, hashed_password=hashed_password)
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user


# Authenticates a user by username and password
def authenticate_user(db: Session, username: str, password: str) -> models.User | bool:
    user = get_user(db, username)
    if not user:
        return False
    if not pwd_context.verify(password, user.hashed_password):
        return False
    return user


# Encodes data into a JWT token
def create_access_token(data: dict, expires_delta: timedelta | None = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=15)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt
