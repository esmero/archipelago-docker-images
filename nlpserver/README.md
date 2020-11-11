##  Esmero-nlp NPLWEB64 docker image

NLP Archipelago Project built on slim python base image using NLP WEB64 project
Based on https://github.com/Surt/nlpserver

### Building the image
```SHELL
$ docker build -t esmero-nlp:1.0 .
````

### Configuration and startup

Add to your docker compose file exposing port 6400 or run directly
docker run --publish 6400:6400 --detach --name esmero-nlp esmero-nlp:1.0  

For CoreNLP on another container run:
```
docker run -p 9000:9000 nlpbox/corenlp
``` 
