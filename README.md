# Fly Conda Test

Test anaconda package

## Build Codes

### Environment: base

```shell
conda install conda-build
conda update conda-build

conda install anaconda-client

conda-build recipe

anaconda login

anaconda upload /root/miniconda3/conda-bld/noarch/fly_conda_test-0.2.1-py_0.tar.bz2 -u firesimulations

conda convert --platform all /root/miniconda3/conda-bld/noarch/fly_conda_test-0.2.1-py_0.tar.bz2 -o dist/
```

### Environment: own

```shell
conda env create -f environment.yml

conda activate fly_conda_build_environment
conda deactivate
conda remove -n fly_conda_build_environment --all
conda env update --file environment.yml --prune

conda config --get channels
conda config --add channels conda-forge
conda config --remove channels conda-forge

conda config --set channel_priority strict
conda config --set channel_priority flexible
conda config --set channel_priority disabled

conda-build recipe

anaconda login

anaconda upload /root/miniconda3/envs/fly_conda_build_environment/conda-bld/noarch/fly_conda_test-0.2.1-py_0.tar.bz2 -u firesimulations
conda convert --platform all /root/miniconda3/envs/fly_conda_build_environment/conda-bld/noarch/fly_conda_test-0.2.1-py_0.tar.bz2 -o dist/
conda convert --platform linux-32 /root/miniconda3/envs/fly_conda_build_environment/conda-bld/linux-64/fly_conda_test-0.10.0-py311_0.tar.bz2 -o dist/
conda convert --platform win-32 /root/miniconda3/envs/fly_conda_build_environment/conda-bld/linux-64/fly_conda_test-0.10.0-py311_0.tar.bz2 -o dist/
anaconda upload ./dist/*/* -u firesimulations
```
