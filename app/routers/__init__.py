from fastapi import APIRouter
from .users import router as user_router
from .pets import router as pet_router
router = APIRouter()

router.include_router(user_router)
router.include_router(pet_router)