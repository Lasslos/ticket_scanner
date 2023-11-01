import enum

from sqlalchemy import Column, Integer, String, Boolean, DateTime, Enum

from database.database import dbBase


# The database models. These are SQLAlchemy models.

class TicketType(str, enum.Enum):
    student = "student"
    volunteer = "volunteer"


class Ticket(dbBase):
    __tablename__ = "tickets"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, unique=True, index=True)
    type = Column(Enum(TicketType))
    created = Column(DateTime, server_default="func.now()")
    notes = Column(String, default="")
    entered = Column(DateTime, nullable=True)
    is_present = Column(Boolean, default=False)


class User(dbBase):
    username = Column(String, primary_key=True, index=True)
    hashed_password = Column(String)
