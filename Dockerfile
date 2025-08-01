FROM python:3.11-slim

# 安裝 CalculiX
RUN apt-get update && apt-get install -y calculix-ccx \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . /app

# 先升級 pip，並明確升級 numpy 到完整版（重要！）
RUN pip install --upgrade pip && pip install "numpy>=1.26.0"

# 再安裝其他 Python 套件
RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 3000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "3000"]
