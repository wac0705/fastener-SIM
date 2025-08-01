FROM python:3.11-slim

# 基本系統依賴
RUN apt-get update && \
    apt-get install -y wget bzip2 gmsh && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# 安裝 ElmerFEM 官方 Linux 版 (請看官網最新 Release)
ENV ELMER_DIR /opt/elmerfem
RUN wget -O /tmp/ElmerFEM.tar.bz2 https://github.com/ElmerCSC/elmerfem/releases/download/release-9.0/ElmerFEM-9.0-linux-x86_64-binaries.tar.bz2 && \
    mkdir -p $ELMER_DIR && \
    tar -xjf /tmp/ElmerFEM.tar.bz2 -C $ELMER_DIR --strip-components=1 && \
    rm /tmp/ElmerFEM.tar.bz2
ENV PATH $ELMER_DIR/bin:$PATH
ENV LD_LIBRARY_PATH $ELMER_DIR/lib:$LD_LIBRARY_PATH

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

# 建立 py312 環境並安裝科學大包
RUN conda create -y -n py312 python=3.12 && \
    conda run -n py312 conda install -y -c conda-forge sfepy matplotlib python-multipart numpy

# 後續所有 SHELL 指令都在 py312 環境
SHELL ["conda", "run", "-n", "py312", "/bin/bash", "-c"]

WORKDIR /app
COPY . /app

RUN pip install --upgrade pip
RUN pip install fastapi uvicorn

EXPOSE 3000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "3000"]
