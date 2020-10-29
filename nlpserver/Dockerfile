# From https://hub.docker.com/_/python 
# using slim buster because docs say alpine makes python building slower

FROM python:3.9.0-slim-buster

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y curl supervisor

WORKDIR /usr/src
RUN curl -L "https://github.com/web64/nlpserver/archive/v1.0.1.tar.gz" -O
RUN tar -xzf "v1.0.1.tar.gz"
RUN rm "v1.0.1.tar.gz" && mv nlpserver-1.0.1 nlpserver
WORKDIR /usr/src/nlpserver

RUN apt-get -y install pkg-config && \
    apt-get -y install -y python-numpy libicu-dev && \
    apt-get -y install -y python3-pip && \
    python3 -m pip install --default-timeout=100 -r requirements.txt
# English, spanish and Italian
# TODO add this as built time arguments
RUN polyglot download LANG:en
RUN polyglot download LANG:es
RUN polyglot download LANG:it

RUN python3 -m spacy download en && \
    python3 -m spacy download xx && \
    python3 -m spacy download es && \
    python3 -m spacy download it

 # Supervisor
COPY nlpserver.conf /etc/supervisor/conf.d
COPY entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

EXPOSE 6400
