[![Docker Image CI](https://github.com/mattgalbraith/subread-docker-singularity/actions/workflows/docker-image.yml/badge.svg)](https://github.com/mattgalbraith/subread-docker-singularity/actions/workflows/docker-image.yml)

# subread-docker-singularity

## Build Docker container for Subread package and (optionally) convert to Apptainer/Singularity.  

The Subread package comprises a suite of software programs for processing next-gen sequencing read data including Subread, featureCounts, Sublong.  
https://subread.sourceforge.net/  
http://bioconductor.org/packages/release/bioc/html/Rsubread.html  
  
#### Requirements:
See Dockerfile for build requirements  
To run: Python2 interpreter in PATH
  
## Build docker container:  

### 1. For Subread installation instructions:  
https://github.com/ShiLab-Bioinformatics/subread#readme  

### 2. Build the Docker Image

#### To build image from the command line:  
``` bash
# Assumes current working directory is the top-level subread-docker-singularity directory
docker build -t subread:2.0.4 . # tag should match software version
```
* Can do this on [Google shell](https://shell.cloud.google.com)

* Alternative build using Bioconda/µmamba (Currently up to 2.0.3 available):
``` bash
# Assumes current working directory is the top-level subread-docker-singularity directory
docker build -t subread:2.0.3 -f Dockerfile_micromamba . # tag should match software version
```

#### To test this tool from the command line:
``` bash
docker run --rm -it subread:2.0.4 featureCounts -v
```

## Optional: Conversion of Docker image to Singularity  

### 3. Build a Docker image to run Singularity  
(skip if this image is already on your system)  
https://github.com/mattgalbraith/singularity-docker

### 4. Save Docker image as tar and convert to sif (using singularity run from Docker container)  
``` bash
docker images
docker save <Image_ID> -o subread2.0.4-docker.tar && gzip subread2.0.4-docker.tar # = IMAGE_ID of Subread image
docker run -v "$PWD":/data --rm -it singularity:1.1.5 bash -c "singularity build /data/subread2.0.4.sif docker-archive:///data/subread2.0.4-docker.tar.gz"
```
NB: On Apple M1/M2 machines ensure Singularity image is built with x86_64 architecture or sif may get built with arm64  

Next, transfer the subread2.0.4.sif file to the system on which you want to run Subread from the Singularity container  

### 5. Test singularity container on (HPC) system with Singularity/Apptainer available  
``` bash
# set up path to the Singularity container
SUBREAD_SIF=path/to/subread2.0.4.sif

# Test that Subread can run from Singularity container
singularity run $SUBREAD_SIF featureCounts -v # depending on system/version, singularity may be called apptainer
```