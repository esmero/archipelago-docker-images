# From https://hub.docker.com/_/python 
# using slim buster because docs say alpine makes python building slower

FROM python:3.10.1-slim-buster

# Use the Architecture to decide on pycld
ARG TARGETPLATFORM


RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y curl supervisor

WORKDIR /usr/src
RUN curl -L "https://github.com/web64/nlpserver/archive/v1.0.1.tar.gz" -O
RUN tar -xzf "v1.0.1.tar.gz"
RUN rm "v1.0.1.tar.gz" && mv nlpserver-1.0.1 nlpserver
WORKDIR /usr/src/nlpserver

RUN apt-get -y install pkg-config && \
    apt-get install build-essential git software-properties-common -y && rm -rf /var/lib/apt/lists/*
RUN apt-get update &&  apt-get -y install -y python-dev python-numpy python3-dev libevent-dev libicu-dev && \
    apt-get -y install -y python3-pip && rm -rf /var/lib/apt/lists/* 
# We can't use requirements.txt because of custom ARM64 pycld2
RUN python3 -m pip install --no-cache-dir --default-timeout=100 newspaper3k
RUN if [ "$TARGETPLATFORM" = "linux/amd64" ]; then BRANCH=master; elif [ "$TARGETPLATFORM" = "linux/arm/v7" ]; then BRANCH=aarch64; elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then BRANCH=aarch64; else BRANCH=master; fi \
  && python3 -m pip install --no-cache-dir --default-timeout=100 -e git+git://github.com/DiegoPino/pycld2.git@${BRANCH}#egg=pycld2
# RUN python3 -m pip install --no-cache-dir --default-timeout=100 -e git+git://github.com/DiegoPino/pycld2.git@aarch64#egg=pycld2
RUN python3 -m pip install --no-cache-dir --default-timeout=100 gensim 
RUN python3 -m pip install --no-cache-dir --default-timeout=100 pyicu numpy Flask morfessor langid BeautifulSoup4 afinn textblob
RUN python3 -m pip install --no-cache-dir --default-timeout=100 spacy
RUN python3 -m pip install --no-cache-dir --default-timeout=100 polyglot
RUN python3 -m pip install --no-cache-dir --default-timeout=100 readability-lxml

# English, spanish and Italian
# TODO add this as built time arguments
RUN polyglot download LANG:en && \
    polyglot download LANG:es && \
    polyglot download LANG:it && \
    polyglot download LANG:pt && \
    polyglot download LANG:de && \
    polyglot download LANG:hi


RUN python3 -m spacy download en && \
    python3 -m spacy download xx && \
    python3 -m spacy download es && \
    python3 -m spacy download pt && \
    python3 -m spacy download de && \
    python3 -m spacy download it 

 # Supervisor
COPY nlpserver.conf /etc/supervisor/conf.d
COPY entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

EXPOSE 6400
