import os
os.environ["DATABASE_URL"] = "sqlite:///./test.db"

from fastapi.testclient import TestClient
from app.db import Base, engine
from app.main import app

# TestClient without "with" never runs the startup event, so create the tables here.
Base.metadata.drop_all(bind=engine)
Base.metadata.create_all(bind=engine)
client = TestClient(app)

def test_health():
    assert client.get("/health").json() == {"status": "UP"}

def test_root():
    response = client.get("/")
    assert response.status_code == 200
    assert response.json()["service"] == "TaskBoard API"

def test_create_task_validation():
    response = client.post("/api/tasks", json={"title": "Deploy application", "priority": "HIGH", "assignee": "Student"})
    assert response.status_code == 201
    assert response.json()["title"] == "Deploy application"

def test_create_task_rejects_empty_title():
    response = client.post("/api/tasks", json={"title": ""})
    assert response.status_code == 422

def test_list_and_get_task():
    created = client.post("/api/tasks", json={"title": "Write Helm chart"}).json()
    assert any(t["id"] == created["id"] for t in client.get("/api/tasks").json())
    assert client.get(f"/api/tasks/{created['id']}").json()["title"] == "Write Helm chart"

def test_update_task():
    created = client.post("/api/tasks", json={"title": "Add HPA"}).json()
    response = client.put(f"/api/tasks/{created['id']}", json={"status": "DONE"})
    assert response.status_code == 200
    assert response.json()["status"] == "DONE"

def test_delete_task():
    created = client.post("/api/tasks", json={"title": "Temporary task"}).json()
    assert client.delete(f"/api/tasks/{created['id']}").status_code == 204
    assert client.get(f"/api/tasks/{created['id']}").status_code == 404

def test_stats():
    client.post("/api/tasks", json={"title": "Stats task", "status": "IN_PROGRESS"})
    stats = client.get("/api/tasks/stats").json()
    assert stats["total"] >= 1
    assert stats["inProgress"] >= 1
