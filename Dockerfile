FROM python:3.11-slim

RUN apt-get update && apt-get install -y wget bzip2 && apt-get clean && rm -rf /var/lib/apt/lists/*

ENV CONDA_DIR /opt/conda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    bash ~/miniconda.sh -b -p $CONDA_DIR && \
    rm ~/miniconda.sh
ENV PATH $CONDA_DIR/bin:$PATH

RUN conda config --set always_yes yes && \
    conda config --set channel_priority strict

# 這行會自動同意 channel 條款
RUN conda info

RUN conda install -y -c conda-forge elmerfem gmsh sfepy matplotlib python-multipart numpy

WORKDIR /app
COPY . /app

RUN pip install --upgrade pip
RUN pip install fastapi uvicorn

EXPOSE 3000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "3000"]
