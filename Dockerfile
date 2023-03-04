################## BASE IMAGE ######################
FROM --platform=linux/amd64 ubuntu:20.04 as build
# need to specify platform in case build is on arm64 system

################## INSTALLATION ######################
ENV DEBIAN_FRONTEND noninteractive
ENV PACKAGES wget ca-certificates tar build-essential zlib1g zlib1g-dev libpthread-stubs0-dev

RUN apt-get update && \
    apt-get install -y --no-install-recommends ${PACKAGES} && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Get source, make, and install Subread 
RUN wget https://sourceforge.net/projects/subread/files/subread-2.0.4/subread-2.0.4-source.tar.gz && \
    tar -xzvf subread-2.0.4-source.tar.gz && \
    cd subread-2.0.4-source/src && \
    make -f Makefile.Linux && \
    cd ../ && \
    sh test/test_all.sh

################## 2ND STAGE ######################
# Second stage to make smaller container (in this case 560MB --> 176MB)
# see https://docs.docker.com/build/building/multi-stage/
# can also stop at specific stage for debugging eg docker build --target build -t subread:2.0.4
FROM --platform=linux/amd64 ubuntu:20.04

################## METADATA ######################
LABEL base_image="ubuntu:20.04"
LABEL version="1.0.0"
LABEL software="Subread"
LABEL software.version="2.0.4"
LABEL about.summary="The Subread package comprises a suite of software programs for processing next-gen sequencing read data including Subread, featureCounts, Sublong."
LABEL about.home="https://subread.sourceforge.net/"
LABEL about.documentation="https://subread.sourceforge.net/SubreadUsersGuide.pdf"
LABEL about.license_file=""
LABEL about.license="GPL-3.0-only"

################## MAINTAINER ######################
MAINTAINER Matthew Galbraith <matthew.galbraith@cuanschutz.edu>

ENV DEBIAN_FRONTEND noninteractive
ENV PACKAGES python

RUN apt-get update && \
    apt-get install -y --no-install-recommends ${PACKAGES} && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY --from=build /subread-2.0.4-source/bin/* /usr/bin/


