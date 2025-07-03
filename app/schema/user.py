from pydantic import BaseModel, Field
#pydantic class payload format of user registration api
class UserCreate(BaseModel):
    username:str = Field(..., max_length=50, min_length=3)
    password:str = Field(...,  min_length=5)

    model_config = dict(from_attributes=True)

#pydantic class to return user info.
class UserOut(BaseModel):
    id: int
    username: str

    model_config = dict(from_attributes=True)

#pydantic class to return user login info.
class UserLogin(BaseModel):
    id : int
    username:str
    access_token:str
    token_type: str = Field(default="bearer")