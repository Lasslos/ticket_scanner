from fastapi import Depends, FastAPI
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session

import ticket
from database import database, schemas
from database.database import engine

database.dbBase.metadata.create_all(bind=engine)

app = FastAPI()

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")


@app.get("/ticket/", response_model=schemas.Ticket)
def get_ticket(ticket_id: int, db: Session = Depends(database.get_db)):
    return ticket.get_ticket(db, ticket_id)


@app.get("/ticket/", response_model=schemas.Ticket)
def get_ticket_by_name(ticket_name: str, db: Session = Depends(database.get_db)):
    return ticket.get_ticket_by_name(db, ticket_name)


@app.get("/tickets/", response_model=list[schemas.Ticket])
def get_tickets(skip: int = 0, limit: int = 100, db: Session = Depends(database.get_db)):
    return ticket.get_tickets(db, skip, limit)


@app.post("/ticket/new", response_model=schemas.Ticket)
def create_ticket(ticket_create: schemas.TicketCreate, db: Session = Depends(database.get_db)):
    return ticket.create_ticket(db, ticket_create)


@app.put("/ticket/update", response_model=schemas.Ticket)
def update_ticket(ticket_update: schemas.TicketUpdate, db: Session = Depends(database.get_db)):
    return ticket.update_ticket(db, ticket_update)


@app.delete("/ticket/delete", response_model=schemas.Ticket)
def delete_ticket(ticket_id: int, db: Session = Depends(database.get_db)):
    return ticket.delete_ticket(db, ticket_id)
