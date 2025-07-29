from fastapi import FastAPI, Depends
from sqlalchemy.orm import Session
from . config.database import get_db
from app.routers import router

app = FastAPI()

@app.get("/")
def index(db: Session = Depends(get_db)):
    return { "message" : "Welcome to the fastapi after the deployment, This app is now deployed to ec2 and the ECS fargate." }

app.include_router(router)