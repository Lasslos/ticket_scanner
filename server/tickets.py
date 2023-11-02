from sqlalchemy.orm import Session

from database import models, schemas


def get_ticket(db: Session, ticket_id: int) -> models.Ticket | None:
    return db.get(models.Ticket, ticket_id)


def get_ticket_by_name(db: Session, ticket_name: str) -> models.Ticket | None:
    return db.query(models.Ticket).filter(models.Ticket.name == ticket_name).first()


def get_tickets(db: Session, skip: int = 0, limit: int = 100) -> list[models.Ticket]:
    return db.query(models.Ticket).offset(skip).limit(limit).all()


def create_ticket(db: Session, ticket: schemas.TicketCreate) -> models.Ticket:
    db_ticket = models.Ticket(**ticket.model_dump())
    db.add(db_ticket)
    db.commit()
    db.refresh(db_ticket)
    return db_ticket


def update_ticket(db: Session, ticket_update: schemas.TicketUpdate) -> models.Ticket:
    db_ticket = get_ticket(db, ticket_update.id)
    ticket_data = ticket_update.model_dump(exclude_unset=True)
    for key, value in ticket_data.items():
        setattr(db_ticket, key, value)
    db.add(db_ticket)
    db.commit()
    db.refresh(db_ticket)
    return db_ticket


def delete_ticket(db: Session, ticket_id: int) -> models.Ticket:
    db_ticket = get_ticket(db, ticket_id)
    db.delete(db_ticket)
    db.commit()
    return db_ticket
