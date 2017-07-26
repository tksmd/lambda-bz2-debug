#
# Dockerfile for building archive
#
# docker build -t lambda-bz2-debug .
# docker run --name=lambda-bz2-debug-build lambda-bz2-debug
# docker cp lambda-bz2-debug-build:/opt/local/app/lambda-bz2-debug.zip .
# docker rm lambda-bz2-debug-build
#
FROM amazonlinux:2016.09
MAINTAINER Takashi Someda <takashi@hacarus.com>

# Python Setup
RUN yum install gcc gcc-c++ gcc-gfortran libgfortran make python-devel -y
RUN yum install zlib-devel openssl-devel bzip2 bzip2-devel readline-devel findutils file zip -y
RUN yum install cpio diffutils -y

RUN mkdir -p /usr/local/src
WORKDIR /usr/local/src

ENV PYTHON_VERSION 3.6.0
RUN curl -skL https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz | tar zxvf -
WORKDIR /usr/local/src/Python-${PYTHON_VERSION}
RUN ./configure --prefix=/usr/local/python3.6 --enable-shared; make ; make install

# Dependent Libraries Setup
RUN yum install blas lapack lapack-devel atlas-devel atlas-sse3-devel -y
RUN mkdir -p /opt/local/app
COPY requirements.txt /opt/local/app/
WORKDIR /opt/local/app
ENV LD_LIBRARY_PATH /usr/local/python3.6/lib
RUN /usr/local/python3.6/bin/python3 -m venv --copies venv
RUN source venv/bin/activate ; pip install --use-wheel -r requirements.txt

COPY build.sh /opt/local/app
COPY lambda_function.py /opt/local/app

ENTRYPOINT ["./build.sh"]
