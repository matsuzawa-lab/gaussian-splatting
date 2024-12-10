FROM nvidia/cuda:11.8.0-devel-ubuntu22.04

# Install base utilities
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y build-essential wget ninja-build unzip libgl-dev ffmpeg\
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install miniconda
ENV CONDA_DIR /opt/conda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda

# Put conda in path so we can use conda activate
ENV PATH=$CONDA_DIR/bin:$PATH

WORKDIR /root/gaussian_splatting
COPY ./ ./

ENV TORCH_CUDA_ARCH_LIST="7.0+PTX"

RUN conda update -n base conda
RUN conda install -n base conda-libmamba-solver
RUN conda config --set solver libmamba
RUN conda env create -f environment.yml
RUN conda init bash

SHELL ["conda", "run", "-n", "gaussian_splatting", "/bin/bash", "-c"]
RUN conda install colmap
RUN conda remove ffmpeg -y

CMD ["/bin/bash"]
