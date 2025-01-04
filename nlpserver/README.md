##  Esmero-nlp NLPWEB64 docker image

NLP Archipelago Project built on slim python base image using NLP WEB64 project
Based on https://github.com/Surt/nlpserver

### Building the image
```SHELL
$ docker build -t esmero/esmero-nlp:1.1 .
````

#### Multiplatform Build

For reference on `docker buildx` usage see [Docker's Multi-platform images documentation](https://docs.docker.com/build/building/multi-platform/).

```docker
docker buildx create --name m1_builder
docker buildx use m1_builder
docker buildx inspect --bootstrap
docker buildx build --platform linux/amd64,linux/arm64 -t esmero/esmero-nlp:1.1-multiarch . --push
```


### Deployed features

- Python 3.12
- facebookresearch/fastText
- polyglot
- spacy
- ML: YOLOV8, ImageNet, InsightFace, Sentence Transformer/Sbert (BAAI/bge-small-en-v1.5)

### Configuration and startup

Add to your docker compose file exposing port 6400 or run directly
docker run --publish 6400:6400 --detach --name esmero-nlp  esmero/esmero-nlp:1.1

For CoreNLP on another container run:
```
docker run -p 9000:9000 esmero/esmero-nlp:1.1
``` 
