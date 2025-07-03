from passlib.context import CryptContext
from jose import jwt, JWTError
from app.config.config import settings
from datetime import datetime,timedelta
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from app.config.database import get_db
from sqlalchemy.orm import Session
from app.models import User

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/users/login")

pwd_context = CryptContext(schemes=['bcrypt'], deprecated='auto')

#create hash from raw password
def hash(password : str):
    return pwd_context.hash(password)

#convert raw password to hashed and verify
def verify_password(password: str, hashed: str):
    return pwd_context.verify(password, hashed)

#create jwt token by encoding user id and username
def create_token(data):
    encode_data = data.copy()
    encode_data['exp'] = datetime.utcnow() + timedelta(minutes=30)
    return jwt.encode(encode_data, settings.secret_key, algorithm=settings.algorithm)

# decode , verify jwt token and return logged in user object
def current_user(token:str = Depends(oauth2_scheme), db:Session = Depends(get_db)):
    try: 
        token_data = jwt.decode(token, key=settings.secret_key, algorithms=[settings.algorithm])
        user_id = token_data.get("id")
    except JWTError :
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Token is invalid!")
    
    if not user_id:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Token is invalid!")
    
    user = db.get(User, user_id)

    if not user:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="User does not exist with this token!")
    
    return user