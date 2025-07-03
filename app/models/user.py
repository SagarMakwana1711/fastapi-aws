from sqlalchemy import Column, Integer, String, DateTime, func
from app.config.database import Base

# sqlalchemy modeo for users
class User(Base):
    __tablename__  = "users"
    id = Column(Integer, primary_key=True,index=True)
    username = Column(String, unique=True, nullable=False, index=True)
    password = Column(String, nullable=False)
    last_login = Column(DateTime(timezone=True),nullable=True)
    created_at = Column(DateTime(timezone=True), nullable=False, server_default=func.now())