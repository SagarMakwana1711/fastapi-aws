from app.schema import PetList, PetCreate, PetUpdate,PetDetail
from fastapi import APIRouter
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.config.database import get_db, save_and_refresh
from app.models import Pet, User
from app.config.security import current_user
from typing import List
#create router instance
router = APIRouter(prefix="/pets", tags=['Pets'])

#find pet by id or return error
def set_pet(db: Session, pet_id: int) :
    pet = db.query(Pet).filter(Pet.id == pet_id).first()
    if pet is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail=f"Pet with id: {pet_id} was not found"
        )
    return pet

#check if logged in user is owner
def is_owner(pet: Pet, user: User):
    if pet.owner_id != user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN, detail="This pet does not belong to you"
        )

#create api for user
@router.post("/", response_model=PetDetail, status_code=status.HTTP_201_CREATED)

def create(pet: PetCreate, db: Session = Depends(get_db), current_user:User = Depends(current_user)):
    pet = Pet(**pet.model_dump(), owner_id=current_user.id)
    save_and_refresh(db,pet)
    return pet

#get available pets list
@router.get("/", response_model=List[PetList], status_code= status.HTTP_200_OK)

def get_available_pets(db: Session = Depends(get_db)):
    pets = db.query(Pet).filter(Pet.adopted == False).all()
    return pets

#view specific pet info.
@router.get("/{id}",response_model=PetDetail)
def show(id:int ,db: Session = Depends(get_db)):
    pet = set_pet(db, id)
    return pet

#update pet
@router.put("/{id}", response_model=PetDetail)
def update(id:int, pet_data : PetUpdate, db:Session = Depends(get_db), user:User = Depends(current_user)):
    pet = set_pet(db, id)
    is_owner(pet, user)

    for key, value in pet_data.model_dump(exclude_unset=True).items():
        setattr(pet, key, value)

    save_and_refresh(db,pet)
    return pet

#delete pet
@router.delete("/{id}",status_code=status.HTTP_204_NO_CONTENT )
def delete(id:int, db:Session = Depends(get_db), user:User = Depends(current_user)):
    pet = set_pet(db, id)
    is_owner(pet, user)
    db.delete(pet)
    db.commit()
    return

#Adopt any specific pet
@router.post("/{id}/adopt", response_model=PetDetail)
def adopt_pet(id: int, db: Session = Depends(get_db), user: User = Depends(current_user)):
    pet = set_pet(db, id)

    if pet.adopted:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="This pet is already adopted")

    pet.adopted = True
    pet.owner_id = user.id
    save_and_refresh(db, pet)
    return pet

