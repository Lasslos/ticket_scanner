from datetime import timedelta
from typing import Annotated

from fastapi import Depends, FastAPI, HTTPException, status
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from sqlalchemy.orm import Session

import tickets
from authentication import user
from authentication.user import Token, authenticate_user, create_access_token, ACCESS_TOKEN_EXPIRE_MINUTES, \
    get_user, ADMIN_HASH, check_password
from database import database, schemas
from database.database import engine

database.dbBase.metadata.create_all(bind=engine)

app = FastAPI()

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/token/")


@app.get("/ticket/", response_model=schemas.Ticket)
def get_ticket(token: Annotated[str, Depends(oauth2_scheme)], ticket_id: int, db: Session = Depends(database.get_db)):
    ticket = tickets.get_ticket(db, ticket_id)
    if ticket is None:
        raise HTTPException(status_code=404, detail="Ticket not found")
    return ticket


@app.get("/tickets/", response_model=list[schemas.Ticket])
def get_tickets(token: Annotated[str, Depends(oauth2_scheme)], skip: int = 0, limit: int = 100, db: Session = Depends(database.get_db)):
    return tickets.get_tickets(db, skip, limit)


@app.post("/ticket/new", response_model=schemas.Ticket)
def create_ticket(token: Annotated[str, Depends(oauth2_scheme)], ticket_create: schemas.TicketCreate, db: Session = Depends(database.get_db)):
    ticket_by_name = tickets.get_ticket_by_name(db, ticket_create.name)
    ticket_by_id = tickets.get_ticket(db, ticket_create.id)
    if ticket_by_id is not None:
        raise HTTPException(status_code=409, detail="Ticket id already exists")
    if ticket_by_name is not None:
        raise HTTPException(status_code=409, detail="Ticket name already exists")
    return tickets.create_ticket(db, ticket_create)


@app.put("/ticket/update", response_model=schemas.Ticket)
def update_ticket(token: Annotated[str, Depends(oauth2_scheme)], ticket_update: schemas.TicketUpdate, db: Session = Depends(database.get_db)):
    ticket_by_name = tickets.get_ticket_by_name(db, ticket_update.name)
    ticket_by_id = tickets.get_ticket(db, ticket_update.id)
    if ticket_by_id is None:
        raise HTTPException(status_code=404, detail="Ticket not found")
    if ticket_by_name is not None and ticket_by_name.id != ticket_by_id.id:
        raise HTTPException(status_code=409, detail="Ticket name already exists")
    return tickets.update_ticket(db, ticket_update)


@app.delete("/ticket/delete", response_model=schemas.Ticket)
def delete_ticket(token: Annotated[str, Depends(oauth2_scheme)], ticket_id: int, db: Session = Depends(database.get_db)):
    return tickets.delete_ticket(db, ticket_id)


# Receives a username and password and returns a JWT token by
# authenticate_user(username, password)
# create_access_token(data, expires_delta)
@app.post("/token/", response_model=Token)
async def login_for_access_token(form_data: Annotated[OAuth2PasswordRequestForm, Depends()],
                                 db: Session = Depends(database.get_db)):
    authenticated_user = authenticate_user(db, form_data.username, form_data.password)
    if not authenticated_user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": authenticated_user.username}, expires_delta=access_token_expires
    )
    return {"access_token": access_token, "token_type": "bearer"}


# Creates a user if the key hash matches the admin hash:
@app.post("/user/new", response_model=schemas.User)
def create_user(user_create: schemas.UserCreate, db: Session = Depends(database.get_db)):
    #print(get_password_hash(user_create.key))
    if not check_password(user_create.key, ADMIN_HASH):
        raise HTTPException(status_code=401, detail="Incorrect admin key")
    user_database = get_user(db, user_create.username)
    if user_database is not None:
        raise HTTPException(status_code=409, detail="Username already exists")
    return user.create_user(db, user_create)
