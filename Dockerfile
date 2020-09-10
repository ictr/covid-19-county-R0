FROM continuumio/miniconda3

RUN conda install -c conda-forge r-readxl r-reshape2 r-stringr -y
RUN conda install -c conda-forge ipykernel pandas matplotlib papermill scipy nbconvert -y
RUN conda install -c conda-forge sos sos-notebook sos-python sos-papermill -y
RUN pip install xlrd
RUN pip install git+https://github.com/vatlab/sos-notebook.git