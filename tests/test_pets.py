def create_payload():
    return {
        "name": "Buddy",
        "breed": "Golden Retriever",
        "age": 2 ,
        "description": "Friendly dog",
    }



def test_create_pet(auth_client):
    payload = create_payload()
    res = auth_client.post("/pets/", json=payload)

    assert res.status_code == 201
    body = res.json()
    assert body["name"] == payload["name"]
    assert body["breed"] == payload["breed"]
    assert body["age"] == payload["age"]
    assert body["adopted"] is False
    assert "id" in body


def test_list_available_pets_includes_new_one(auth_client):
    payload = create_payload()
    pet_id = auth_client.post("/pets/", json=payload).json()["id"]

    res = auth_client.get("/pets/")
    ids = [pet["id"] for pet in res.json()]

    assert pet_id in ids


def test_show_pet(auth_client):
    payload = create_payload()
    pet = auth_client.post("/pets/", json=payload).json()

    res = auth_client.get(f"/pets/{pet['id']}")
    assert res.status_code == 200
    assert res.json()["id"] == pet["id"]


def test_update_pet(auth_client):
    payload = create_payload()
    pet_id = auth_client.post("/pets/", json=payload).json()["id"]

    update_payload = {"name": "Max", "age": 5}
    res = auth_client.put(f"/pets/{pet_id}", json=update_payload)

    assert res.status_code == 200
    body = res.json()
    assert body["name"] == "Max"
    assert body["age"] == 5


def test_adopt_pet_removes_from_available(auth_client):
    payload = create_payload()
    pet_id = auth_client.post("/pets/", json=payload).json()["id"]

    res = auth_client.post(f"/pets/{pet_id}/adopt")
    assert res.status_code == 200
    assert res.json()["adopted"] is True

    res = auth_client.get("/pets/")
    ids = [pet["id"] for pet in res.json()]
    assert pet_id not in ids


def test_delete_pet(auth_client):
    payload = create_payload()
    pet_id = auth_client.post("/pets/", json=payload).json()["id"]

    res = auth_client.delete(f"/pets/{pet_id}")
    assert res.status_code == 204

    res = auth_client.get(f"/pets/{pet_id}")
    assert res.status_code == 404
