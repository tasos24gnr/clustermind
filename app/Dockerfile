# 1. Base Image: slim version for reproducability
FROM python:3.12-slim

#2. Dont buffer, logs appear immediately 
ENV PYTHONUNBUFFERED=1 

#3. wORK INSIDE /APP IN THE CONTAINER
WORKDIR /app

#4. Copy only the dependency list - layer caching
COPY requirements.txt .

# 5. Install deps. 
RUN pip install --no-cache-dir -r requirements.txt

COPY main.py .

RUN useradd --create-home appuser
USER appuser

EXPOSE 8000

CMD ["uvicorn","main:app","--host","0.0.0.0","--port","8000"]
