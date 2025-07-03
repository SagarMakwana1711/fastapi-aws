import random
import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.main import app
from app.config.database import get_db, Base
from app.config.config import settings
from app.config.security import create_token

TEST_SQLALCHEMY_URL = (
    f"postgresql://{settings.db_user}:"
    f"{settings.db_password}@{settings.db_host}/petadoption"
)

engine = create_engine(TEST_SQLALCHEMY_URL, pool_pre_ping=True)
TestingSessionLocal = sessionmaker(bind=engine, autocommit=False, autoflush=False)


@pytest.fixture(scope="session")
def session():
    Base.metadata.drop_all(bind=engine)
    Base.metadata.create_all(bind=engine)
    db = TestingSessionLocal()
    try:
        yield db
    finally:
        db.close()


@pytest.fixture()
def client(session):
    def _override_get_db():
        try:
            yield session
        finally:
            session.close()

    app.dependency_overrides[get_db] = _override_get_db
    return TestClient(app)


@pytest.fixture()
def user_payload():
    return {
        "username": f"tester{random.randint(1000, 9999)}",
        "password": "password123",
    }


@pytest.fixture()
def test_user(client, user_payload):
    res = client.post("/users/", json=user_payload)
    assert res.status_code == 201
    return res.json()


@pytest.fixture()
def token(test_user):
    return create_token(
        {"id": test_user["id"], "username": test_user["username"]}
    )


@pytest.fixture()
def auth_client(client, token):
    client.headers.update({"Authorization": f"Bearer {token}"})
    return client
