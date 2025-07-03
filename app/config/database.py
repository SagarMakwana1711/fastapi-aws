from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base
from .config import settings
#sqlalchemi database url
SQLALCHEMY_DATABASE_URL = (
    f"postgresql+psycopg2://{settings.db_user}:"
    f"{settings.db_password}@{settings.db_host}:"
    f"{settings.db_port}/{settings.db_name}"
)
# Database engine
engine = create_engine(SQLALCHEMY_DATABASE_URL,pool_pre_ping=True)

# database session
SessionLocal = sessionmaker(bind=engine, autocommit=False, autoflush=False)
Base = declarative_base()

# get db session 
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
# reusable api method to save and refresh database
def save_and_refresh(db, obj):
    db.add(obj)
    db.commit()
    db.refresh(obj)
    return obj
