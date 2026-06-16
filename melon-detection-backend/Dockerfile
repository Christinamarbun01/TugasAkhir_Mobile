FROM python:3.11.9-slim

WORKDIR /app

# install system deps
RUN apt-get update && apt-get install -y \
    libgl1 \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# 👉 copy requirements dulu (biar cache kepakai)
COPY requirements.txt .

# 👉 install deps (akan di-cache kalau requirements.txt tidak berubah)
RUN pip install --upgrade pip && \
    pip install --cache-dir /root/.cache/pip -r requirements.txt

# 👉 baru copy semua project
COPY . .

EXPOSE 5000

CMD ["python", "app.py"]