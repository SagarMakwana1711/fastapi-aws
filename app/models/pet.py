from sqlalchemy import Column, Integer, String, DateTime, func, Boolean, ForeignKey
from app.config.database import Base
from sqlalchemy.orm import relationship
# sqlalchemy modeo for pets
class Pet(Base):
    __tablename__ = "pets"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    breed = Column(String, nullable=False)
    age = Column(Integer, nullable=False)
    description = Column(String, nullable=False)
    adopted = Column(Boolean, default=False, server_default="false", nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    owner_id = Column(Integer,ForeignKey('users.id', ondelete='CASCADE'), nullable=False )

    owner = relationship('User')