from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.config.database import get_db,save_and_refresh
from app.models import User
from app.schema.user import UserCreate, UserOut, UserLogin
from app.config.security import hash, verify_password,create_token
from fastapi.security import OAuth2PasswordRequestForm

#create router instance
router = APIRouter(prefix="/users", tags=["users"])

#register specific user
@router.post("/", response_model=UserOut, status_code=status.HTTP_201_CREATED)

def create_user(payload: UserCreate, db: Session = Depends(get_db)):
    existing = db.query(User).filter(User.username == payload.username).first()
    if existing:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Username already exists, please try some other name")

    user = User(username=payload.username, password=hash(payload.password))
    save_and_refresh(db,user)
    return user

#login user
@router.post("/login", response_model=UserLogin)
def login(form: OAuth2PasswordRequestForm = Depends(), db:Session = Depends(get_db)):
    user = db.query(User).filter(User.username == form.username).first()

    if not user or not verify_password(form.password, user.password):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail= "Invalid username or password")
    
    return {
        "id" : user.id,
        "username": user.username,
        "access_token" : create_token({ "id" : user.id, "username" : user.username }),
        "token_type": "Bearer"
    }