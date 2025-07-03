
from pydantic import BaseModel, Field
from datetime import datetime
from typing import Optional
from .user import UserOut

#pydantic class for list of pets
class PetList(BaseModel):
    id:int
    name: str
    breed: str
    age: int
    description: str
    model_config = dict(from_attributes=True)

#pydantic class for detail for one pet
class PetDetail(BaseModel):
    id:int
    name: str
    breed: str
    age: int
    description: str
    adopted: Optional[bool]
    owner: UserOut
    model_config = dict(from_attributes=True)

#pydantic class payload format of create api
class PetCreate(BaseModel):
    name: str = Field(..., min_length=1, max_length=100)
    breed: str = Field(..., min_length=1, max_length=100)
    age: int = Field(..., ge=0)
    description: str

    model_config = dict(from_attributes=True)

#pydantic class payload format of update api
class PetUpdate(BaseModel):
    name:        Optional[str] = Field(None, min_length=1, max_length=100)
    breed:       Optional[str] = Field(None, min_length=1, max_length=100)
    age:         Optional[int] = Field(None, ge=0)
    description: Optional[str] = None

    model_config = dict(from_attributes=True)
