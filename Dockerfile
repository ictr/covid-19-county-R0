FROM continuumio/miniconda3

RUN conda install -c conda-forge r-readxl r-reshape2 r-stringr -y
RUN conda install -c conda-forge ipykernel pandas matplotlib papermill scipy nbconvert -y
RUN conda install -c conda-forge sos sos-notebook==0.21.10 sos-python sos-papermill -y