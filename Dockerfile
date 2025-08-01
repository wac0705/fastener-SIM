FROM python:3.11-slim

# 安裝 wget、bzip2 讓 conda 能用
RUN apt-get update && apt-get install -y wget bzip2 && apt-get clean && rm -rf /var/lib/apt/lists/*

# 安裝 Miniconda
ENV CONDA_DIR /opt/conda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    bash ~/miniconda.sh -b -p $CONDA_DIR && \
    rm ~/miniconda.sh
ENV PATH $CONDA_DIR/bin:$PATH

# 關鍵！自動接受條款＋設好優先級
RUN conda config --set always_yes yes && \
    conda config --set channel_priority strict && \
    conda config --set accept_channel_terms true

# 用 conda 安裝 elmerfem、gmsh、sfepy 等理工科學計算套件
RUN conda install -y -c conda-forge elmerfem gmsh sfepy matplotlib python-multipart numpy

WORKDIR /app
COPY . /app

# pip 安裝 FastAPI 與 Uvicorn（Web 伺服器）
RUN pip install --upgrade pip
RUN pip install fastapi uvicorn

EXPOSE 3000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "3000"]
