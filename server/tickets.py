from sqlalchemy.orm import Session

from database import models, schemas


def get_ticket(db: Session, ticket_id: int) -> models.Ticket | None:
    return db.query(models.Ticket).filter(models.Ticket.id == ticket_id).first()


def get_ticket_by_name(db: Session, ticket_name: str) -> models.Ticket | None:
    return db.query(models.Ticket).filter(models.Ticket.name == ticket_name).first()


def get_tickets(db: Session, skip: int = 0, limit: int = 100) -> list[models.Ticket]:
    return db.query(models.Ticket).offset(skip).limit(limit).all()


def create_ticket(db: Session, ticket: schemas.TicketCreate) -> models.Ticket:
    db_ticket = models.Ticket(**ticket.dict())
    db.add(db_ticket)
    db.commit()
    db.refresh(db_ticket)
    return db_ticket


def update_ticket(db: Session, ticket: schemas.TicketUpdate) -> models.Ticket:
    db_ticket = models.Ticket(**ticket.dict())
    db.add(db_ticket)
    db.commit()
    db.refresh(db_ticket)
    return db_ticket


def delete_ticket(db: Session, ticket_id: int) -> models.Ticket:
    db_ticket = db.query(models.Ticket).filter(models.Ticket.id == ticket_id).first()
    db.delete(db_ticket)
    db.commit()
    return db_ticket
