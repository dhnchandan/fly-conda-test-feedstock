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

anaconda upload /root/miniconda3/conda-bld/noarch/fly_conda_test-0.2.0-py_0.tar.bz2 -u firesimulations
```

### Environment: own

```shell
conda env create -f environment.yml

conda activate fly_conda_build_environment

anaconda login

anaconda upload /root/miniconda3/conda-bld/noarch/fly_conda_test-0.2.0-py_0.tar.bz2 -u firesimulations
```
