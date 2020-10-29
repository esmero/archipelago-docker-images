# From https://hub.docker.com/_/python 
# using slim buster because docs say alpine makes python building slower

FROM python:3.9.0-slim-buster

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y git && \
    apt-get install -y supervisor

WORKDIR /usr/src
RUN wget https://github.com/web64/php-nlp-client/archive/v0.40.5.tar.gz && \ 
    tar -xzf v0.40.5.tar.gz
WORKDIR /usr/src/nlpserver

RUN apt-get -y install pkg-config && \
  	apt-get -y install -y python-numpy libicu-dev && \
  	apt-get -y install -y python3-pip && \
  	python3 -m pip install -r requirements.txt
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
