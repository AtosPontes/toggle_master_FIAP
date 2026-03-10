import importlib
import os
import sys
from unittest.mock import patch


class _DummySession:
    class _DummySQS:
        pass

    class _DummyDynamo:
        pass

    def client(self, service_name):
        if service_name == "sqs":
            return self._DummySQS()
        if service_name == "dynamodb":
            return self._DummyDynamo()
        raise ValueError(f"unexpected service: {service_name}")


class _DummyThread:
    def __init__(self, target=None, daemon=None):
        self.target = target
        self.daemon = daemon

    def start(self):
        return None


def _load_module():
    os.environ["AWS_REGION"] = "us-east-1"
    os.environ["AWS_SQS_URL"] = "https://sqs.us-east-1.amazonaws.com/123456789012/fila"
    os.environ["AWS_DYNAMODB_TABLE"] = "ToggleMasterAnalytics"

    sys.modules.pop("app", None)
    with patch("boto3.Session", return_value=_DummySession()), patch("threading.Thread", _DummyThread):
        return importlib.import_module("app")


def test_health_endpoint():
    module = _load_module()
    client = module.app.test_client()

    response = client.get("/health")

    assert response.status_code == 200
    assert response.get_json() == {"status": "ok"}

