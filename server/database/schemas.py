from datetime import datetime

from pydantic import BaseModel

from database.models import TicketType


class TicketBase(BaseModel):
    id: int
    name: str
    type: TicketType
    notes: str = ""
    entered: datetime | None = None
    is_present: bool = False


class TicketCreate(TicketBase):
    pass


class TicketUpdate(BaseModel):
    id: int
    name: str | None = None
    type: TicketType | None = None
    notes: str | None = None
    entered: datetime | None = None
    is_present: bool | None = None
    pass


class Ticket(TicketBase):
    created: datetime

    class Config:
        from_attributes = True


class UserBase(BaseModel):
    username: str


class UserCreate(UserBase):
    password: str
    key: str


class User(UserBase):
    class Config:
        from_attributes = True
