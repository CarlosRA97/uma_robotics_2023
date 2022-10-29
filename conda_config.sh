#!/bin/bash

conda config --append channels conda-forge
conda config --append channels anaconda
conda config --get channels
conda create -n robotics-notebooks python=3.10.6
conda install -n robotics-notebooks -c conda-forge jupyterlab
conda install -n robotics-notebooks --file requirements.txt

conda init zsh
conda init bash
conda init fish
conda activate robotics-notebooks
