import importlib
import os
import sys
from unittest.mock import patch


class _DummyPool:
    def getconn(self):
        raise AssertionError("DB connection should not be used in this test")

    def putconn(self, _conn):
        return None


def _load_module():
    os.environ["DATABASE_URL"] = "postgresql://user:pass@localhost:5432/targeting_db"
    os.environ["AUTH_SERVICE_URL"] = "http://auth-service:8001"

    sys.modules.pop("app", None)
    with patch("psycopg2.pool.SimpleConnectionPool", return_value=_DummyPool()):
        return importlib.import_module("app")


def test_health_endpoint():
    module = _load_module()
    client = module.app.test_client()

    response = client.get("/health")

    assert response.status_code == 200
    assert response.get_json() == {"status": "ok"}


def test_rules_requires_authorization_header():
    module = _load_module()
    client = module.app.test_client()

    response = client.get("/rules/feature-x")

    assert response.status_code == 401
    assert response.get_json()["error"] == "Authorization header obrigatório"
