from datetime import timedelta, datetime
from typing import Annotated

from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from jose import jwt, JWTError
from passlib.context import CryptContext
from pydantic import BaseModel

from database import dbBase
from main import oauth2_scheme, app

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


# Represents a user in the database
class User(BaseModel):
    username: str
    hashed_password: str


pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def get_password_hash(password):
    return pwd_context.hash(password)


# TODO: Add your own user database
def get_user(username: str):
    return User(username=username, hashed_password=get_password_hash("password"))


# Authenticates a user by username and password
def authenticate_user(username: str, password: str):
    user = get_user(username)
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


# Decodes a JWT token and looks up the user in the database
async def get_current_user(token: Annotated[str, Depends(oauth2_scheme)]):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get("sub")
        if username is None:
            raise credentials_exception
        token_data = TokenData(username=username)
    except JWTError:
        raise credentials_exception
    user = get_user(username=token_data.username)
    if user is None:
        raise credentials_exception
    return user


# Receives a username and password and returns a JWT token by
# authenticate_user(username, password)
# create_access_token(data, expires_delta)
@app.post("/token", response_model=Token)
async def login_for_access_token(form_data: Annotated[OAuth2PasswordRequestForm, Depends()]):
    user = authenticate_user(form_data.username, form_data.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.username}, expires_delta=access_token_expires
    )
    return {"access_token": access_token, "token_type": "bearer"}
