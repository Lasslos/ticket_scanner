from datetime import datetime

from pydantic import BaseModel

from models import TicketType


class TicketBase(BaseModel):
    name: str
    type: TicketType
    created: datetime
    notes: str = ""
    entered: datetime | None = None
    is_present: bool = False


class TicketCreate(TicketBase):
    pass


class Ticket(TicketBase):
    id: int

    class Config:
        orm_mode = True


class UserBase(BaseModel):
    username: str


class UserCreate(UserBase):
    password: str


class User(UserBase):
    class Config:
        orm_mode = True
