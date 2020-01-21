FROM ubuntu:18.04 as builder

USER root

# Locale
ENV LC_ALL C
ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8

# ALL tool versions used by opt-build.sh
ENV VER_TRIODENOVO="0.06"

RUN apt-get -yq update
RUN apt-get install -yq \
build-essential \
libbz2-dev \
zlib1g-dev \
curl

RUN apt-get install -yq \
gcc-6 \
g++-6 \
g++-6-multilib \
gfortran-6

RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-6 60 --slave /usr/bin/g++ g++ /usr/bin/g++-6 --slave /usr/bin/gfortran gfortran /usr/bin/gfortran-6

ENV OPT /opt/wsi-t113
ENV PATH $OPT/bin:$PATH
ENV LD_LIBRARY_PATH $OPT/lib

ADD build/opt-build.sh build/
RUN bash build/opt-build.sh $OPT

FROM ubuntu:18.04

LABEL maintainer="vo1@sanger.ac.uk" \
      version="0.06" \
      description="Triodenovo container"

MAINTAINER  Victoria Offord <vo1@sanger.ac.uk>

RUN apt-get -yq update

ENV OPT /opt/wsi-t113
ENV PATH $OPT/bin:$OPT/python3/bin:$OPT/triodenovo/bin:$PATH
ENV LD_LIBRARY_PATH $OPT/lib
ENV PYTHONPATH $OPT/python3:$OPT/python3/lib/python3.6/site-packages
ENV LC_ALL C
ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8
ENV DISPLAY=:0

RUN mkdir -p $OPT
COPY --from=builder $OPT $OPT

#Create some usefull symlinks
RUN cd /usr/local/bin && \
    ln -s /usr/bin/python3 python

## USER CONFIGURATION
RUN adduser --disabled-password --gecos '' ubuntu && chsh -s /bin/bash && mkdir -p /home/ubuntu

USER ubuntu
WORKDIR /home/ubuntu

CMD ["/bin/bash"]
