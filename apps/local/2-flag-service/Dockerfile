FROM python:3.9-alpine

WORKDIR /app

COPY app.py .
COPY requirements.txt .

# Keep base OS packages patched so Trivy doesn't fail on fixed critical CVEs.
RUN apk upgrade --no-cache \
    && pip install --no-cache-dir -r requirements.txt

CMD [ "gunicorn", "--bind", "0.0.0.0:8002", "app:app" ]
