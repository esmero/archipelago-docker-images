# From https://hub.docker.com/_/python 
# using slim buster because docs say alpine makes python building slower

FROM python:3.12.3-slim-bookworm

# Use the Architecture to decide on pycld
ARG TARGETPLATFORM


RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y curl unzip supervisor

WORKDIR /usr/src
RUN curl -L "https://github.com/esmero/nlpserver-fasttext/archive/refs/tags/v1.0.3-ML-alpha3.zip" -O
RUN unzip "v1.0.3-ML-alpha3.zip"
RUN rm "v1.0.3-ML-alpha3.zip" && mv nlpserver-fasttext-1.0.3-ML-alpha3 nlpserver
WORKDIR /usr/src/nlpserver

RUN apt-get -y install pkg-config && \
    apt-get install build-essential git software-properties-common -y && rm -rf /var/lib/apt/lists/*
RUN apt-get update &&  apt-get -y install -y python-dev-is-python3 python3-numpy libhdf5-dev libgl1-mesa-glx libevent-dev libicu-dev && \
    apt-get -y install -y python3-pip && rm -rf /var/lib/apt/lists/* 
# We can't use requirements.txt because of custom ARM64 pycld2
RUN python3 -m pip install --no-cache-dir --default-timeout=100 setuptools newspaper3k
RUN if [ "$TARGETPLATFORM" = "linux/amd64" ]; then BRANCH=master; elif [ "$TARGETPLATFORM" = "linux/arm/v7" ]; then BRANCH=aarch64; elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then BRANCH=aarch64; else BRANCH=master; fi \
  && python3 -m pip install --no-cache-dir --default-timeout=100 -e git+https://github.com/DiegoPino/pycld2.git@${BRANCH}#egg=pycld2
# RUN python3 -m pip install --no-cache-dir --default-timeout=100 -e git+git://github.com/DiegoPino/pycld2.git@aarch64#egg=pycld2
RUN python3 -m pip install --no-cache-dir --default-timeout=100 gensim opencv-python-headless
RUN python3 -m pip install --no-cache-dir --default-timeout=100 pyicu numpy Flask morfessor langid BeautifulSoup4 afinn textblob
RUN python3 -m pip install --no-cache-dir --default-timeout=100 spacy
RUN python3 -m pip install --no-cache-dir --default-timeout=100 polyglot onnxruntime
RUN python3 -m pip install --no-cache-dir --default-timeout=100 readability-lxml
RUN python3 -m pip install --no-cache-dir --default-timeout=100 git+https://github.com/facebookresearch/fastText.git
RUN python3 -m pip install --no-cache-dir --default-timeout=100 torch tensorflow
RUN python3 -m pip install --no-cache-dir --default-timeout=100 pillow ultralytics pandas scikit-learn keras insightface mediapipe sentence-transformers
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

# fasttext Language Detection Model & ML Models
RUN curl -L "https://dl.fbaipublicfiles.com/fasttext/supervised-models/lid.176.bin" -O
RUN mkdir -p models/yolo/ && curl -L -o models/yolo/yolov8m.pt https://github.com/ultralytics/assets/releases/download/v8.2.0/yolov8m.pt
RUN curl -L -o models/yolo/yolov8l-oiv7.pt https://github.com/ultralytics/assets/releases/download/v8.2.0/yolov8l-oiv7.pt
RUN mkdir -p models/mobilenet/ && curl -L -o models/mobilenet/mobilenet_v3_large.tflite https://storage.googleapis.com/mediapipe-models/image_embedder/mobilenet_v3_large/float32/1/mobilenet_v3_large.tflite
RUN mkdir -p models/efficientdet/ && curl -L -o models/efficientdet/efficientdet_lite2.tflite https://storage.googleapis.com/mediapipe-models/object_detector/efficientdet_lite2/float32/latest/efficientdet_lite2.tflite
RUN curl -L -o models/mobilenet/ssd_mobilenet_v2.tflite https://storage.googleapis.com/mediapipe-models/object_detector/ssd_mobilenet_v2/float32/latest/ssd_mobilenet_v2.tflite
# Supervisor
COPY nlpserver.conf /etc/supervisor/conf.d
COPY entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

EXPOSE 6400
