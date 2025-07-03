def test_create_user(client):
    username = "user_1"
    payload = {"username": username, "password": "password123"}

    res = client.post("/users/", json=payload)

    assert res.status_code == 201
    body = res.json()
    assert body["username"] == username
    assert "id" in body


def test_login_user(client):
    username = "login_1"
    password = "password123"

    client.post("/users/", json={"username": username, "password": password})

    res = client.post(
        "/users/login",
        data={"username": username, "password": password},
    )

    assert res.status_code == 200
    body = res.json()
    assert body["username"] == username
    assert "access_token" in body
