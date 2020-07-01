FROM continuumio/miniconda3

RUN conda install -c conda-forge r-readxl r-reshape2 r-stringr -y
RUN conda install -c conda-forge ipykernel pandas matplotlib papermill scipy nbconvert -y