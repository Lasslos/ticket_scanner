from datetime import datetime

from pydantic import BaseModel

from database.models import TicketType


class TicketBase(BaseModel):
    id: int
    name: str
    type: TicketType
    created: datetime
    notes: str = ""
    entered: datetime | None = None
    is_present: bool = False


class TicketCreate(TicketBase):
    pass


class TicketUpdate(TicketBase):
    pass


class Ticket(TicketBase):
    class Config:
        orm_mode = True


class UserBase(BaseModel):
    username: str


class UserCreate(UserBase):
    password: str


class User(UserBase):
    class Config:
        orm_mode = True
