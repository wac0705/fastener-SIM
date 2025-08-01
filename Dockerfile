FROM python:3.11-slim

# 安裝 elmerfem, gmsh 及 conda 相關工具
RUN apt-get update && \
    apt-get install -y wget bzip2 elmerfem gmsh && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# 安裝 Miniconda
ENV CONDA_DIR /opt/conda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    bash ~/miniconda.sh -b -p $CONDA_DIR && \
    rm ~/miniconda.sh
ENV PATH $CONDA_DIR/bin:$PATH

RUN conda config --set always_yes yes && \
    conda config --set channel_priority strict

RUN conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main && \
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r

# 建立 py312 環境並安裝科學大包（不含 elmerfem/gmsh，這兩個直接 apt-get）
RUN conda create -y -n py312 python=3.12 && \
    conda run -n py312 conda install -y -c conda-forge sfepy matplotlib python-multipart numpy

# 啟動時自動激活 py312 環境
SHELL ["conda", "run", "-n", "py312", "/bin/bash", "-c"]

WORKDIR /app
COPY . /app

RUN pip install --upgrade pip
RUN pip install fastapi uvicorn

EXPOSE 3000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "3000"]
