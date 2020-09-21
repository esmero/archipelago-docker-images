FROM alpine

RUN apk update && apk upgrade && apk add curl perl perl-dev make gcc build-base wget gnupg alpine-sdk 
RUN set -eux; \
  \
  apk add --no-cache --virtual .build-deps \
    coreutils \
    zlib-dev \
    libxml2-dev \
    libxslt-dev \
    libzip-dev \
    expat-dev \
    openssl-dev \
      # Equivalent of build essentials
    alpine-sdk 

# Tools we want to keep
RUN apk -U add --no-cache \
      bash \
      git openssh \
      wget \
      file \
      curl \
      nano \
      && \
      rm -rf /var/lib/apt/lists/* && \
      rm /var/cache/apk/*

RUN curl -LO https://raw.githubusercontent.com/miyagawa/cpanminus/master/cpanm \
    && chmod +x cpanm \
    && ./cpanm App::cpanminus \
    && rm -fr ./cpanm /root/.cpanm

ENV PERL_CPANM_OPT --verbose --mirror https://cpan.metacpan.org --mirror-only
RUN cpanm Digest::SHA Module::Signature inc::latest && rm -rf ~/.cpanm
#ENV PERL_CPANM_OPT $PERL_CPANM_OPT --verify
ENV PERL_CPANM_OPT $PERL_CPANM_OPT

RUN cpanm Module::Runtime  
RUN cpanm Moo  
RUN cpanm Pod::Coverage Role::Tiny     
RUN cpanm Module::Runtime Sub::Install YAML namespace::autoclean namespace::clean
RUN cpanm XML::LibXML XML::XPath
RUN cpanm Catmandu
RUN cpanm Catmandu::OAI LWP::Protocol::https

# Change to bash since our folks like bash
SHELL ["/bin/bash", "-c"]
WORKDIR /home/catmandu
VOLUME ["/home/catmandu"]
