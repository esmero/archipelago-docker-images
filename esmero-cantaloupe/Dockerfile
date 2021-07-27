# JRE fails to load fonts if there are no standard fonts in the image; This breaks Cantaloups /admin endpoint
# see https://github.com/docker-library/openjdk/issues/73#issuecomment-207816707
# Also make sure you setup temp_pathname in cantaloupe.properties to a safe/stable place since Classes are cached there too.


FROM debian:buster-slim

ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

RUN apt-get update \
    && apt-get install -y --no-install-recommends tzdata curl ca-certificates fontconfig locales \
    && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_VERSION jdk-15.0.2+7

RUN set -eux; \
    ARCH="$(dpkg --print-architecture)"; \
    case "${ARCH}" in \
       aarch64|arm64) \
         ESUM='6e8b6b037148cf20a284b5b257ec7bfdf9cc31ccc87778d0dfd95a2fddf228d4'; \
         BINARY_URL='https://github.com/AdoptOpenJDK/openjdk15-binaries/releases/download/jdk-15.0.2%2B7/OpenJDK15U-jdk_aarch64_linux_hotspot_15.0.2_7.tar.gz'; \
         ;; \
       armhf|armv7l) \
         ESUM='ff39c0380224e419d940382c4d651cb1e6297a794854e0cc459c1fd4973b3368'; \
         BINARY_URL='https://github.com/AdoptOpenJDK/openjdk15-binaries/releases/download/jdk-15.0.2%2B7/OpenJDK15U-jdk_arm_linux_hotspot_15.0.2_7.tar.gz'; \
         ;; \
       ppc64el|ppc64le) \
         ESUM='486f2aad94c5580c0b27c9007beebadfccd4677c0bd9565a77ca5c34af5319f9'; \
         BINARY_URL='https://github.com/AdoptOpenJDK/openjdk15-binaries/releases/download/jdk-15.0.2%2B7/OpenJDK15U-jdk_ppc64le_linux_hotspot_15.0.2_7.tar.gz'; \
         ;; \
       s390x) \
         ESUM='7dc35a8a4ba1ccf6cfe96fcf26e09ed936f1802ca668ca6bf708e2392c35ab6a'; \
         BINARY_URL='https://github.com/AdoptOpenJDK/openjdk15-binaries/releases/download/jdk-15.0.2%2B7/OpenJDK15U-jdk_s390x_linux_hotspot_15.0.2_7.tar.gz'; \
         ;; \
       amd64|x86_64) \
         ESUM='94f20ca8ea97773571492e622563883b8869438a015d02df6028180dd9acc24d'; \
         BINARY_URL='https://github.com/AdoptOpenJDK/openjdk15-binaries/releases/download/jdk-15.0.2%2B7/OpenJDK15U-jdk_x64_linux_hotspot_15.0.2_7.tar.gz'; \
         ;; \
       *) \
         echo "Unsupported arch: ${ARCH}"; \
         exit 1; \
         ;; \
    esac; \
    curl -LfsSo /tmp/openjdk.tar.gz ${BINARY_URL}; \
    echo "${ESUM} */tmp/openjdk.tar.gz" | sha256sum -c -; \
    mkdir -p /opt/java/openjdk; \
    cd /opt/java/openjdk; \
    tar -xf /tmp/openjdk.tar.gz --strip-components=1; \
    rm -rf /tmp/openjdk.tar.gz;

ENV JAVA_HOME=/opt/java/openjdk \
    PATH="/opt/java/openjdk/bin:$PATH"

# Cantaloupe docker starter script
# https://github.com/cantaloupe-project/cantaloupe/releases/tag/v4.1.7
# Build and run: 
# $ sudo docker build -t esmero-cantaloupe .
# $ sudo docker run -d --rm -p 8183:8182 -v ./cantaloupeconfig:/etc/cantaloupe --name esmero-cantaloupe esmero-cantaloupe

# Publish new tag -- PRIVATE
# $ docker login (user diegopino) use your own name folks!
# $ docker build . -t esmero/cantaloupe-s3:4.1.9
# $ docker push esmero/cantaloupe-s3:4.1.9
# If moving from Archipelago beta1 to beta3, see upgrading from 4.0.3 to 4.1.7 https://github.com/cantaloupe-project/cantaloupe/blob/develop/UPGRADING.md#40x--41

ENV CANTALOUPE_VERSION 4.1.10
ENV PKGNAME=graphicsmagick
# 1.3.35 (Released Febr 23, 2020)
ENV PKGVER=1.3.35
# Uses 50% of the memory of 16. Use 16 if dealing with 48/64 bit pixels color
ENV QUANTUMDEPTH=8
ENV PKGSOURCE=http://downloads.sourceforge.net/$PKGNAME/$PKGNAME/$PKGVER/GraphicsMagick-$PKGVER.tar.lz

EXPOSE 8182

RUN apt-get update && apt-get install -y --no-install-recommends \
		ffmpeg \
		wget \
  	        libopenjp2-tools \
                libopenjp2-7-dev \
                liblcms2-dev \
                libpng-dev \
                libzstd-dev \
                libtiff-dev \
                libjpeg-dev \
                libcairo2-dev libjpeg62-turbo-dev libpango1.0-dev libgif-dev build-essential \
                zlib1g-dev \
                libwebp-dev \
                libimage-exiftool-perl \
                ghostscript \
                libgs-dev \
                pkg-config \
                git \
                libexif-dev \
                libc6 \
                lzip \
                zlib1g zlib1g-dev libxml2 libxml2-dev libltdl-dev libpng-dev libtool libopenjp2-7 libtiff-dev cmake automake autoconf make gcc g++ libimage-exiftool-perl  libfreetype6-dev \
                && rm -rf /var/lib/apt/lists/*

# Install TurboJpegProcessor dependencies
RUN mkdir -p /opt/libjpeg-turbo/lib

# Graphicsmagick dependencies
#RUN apk add --no-cache --update g++ \
#                     gcc \
#                     make \
#                     automake \
#                     autoconf \
#                     git \
#                     lzip \
#                     wget \
#                     sdl-dev \
#                     giflib-dev \
#                     libjpeg-turbo-dev \
#                     lcms2-dev \
#                     libwmf-dev \
#                     jasper-dev \
#                     libx11-dev \
#                     libpng-dev \
#                     libtool \
#                     jasper-dev \
#                     bzip2-dev \
#                     zlib-dev \
#                     libxml2-dev \
#                     tiff-dev \
#                     exiftool \
#                     freetype-dev \
#                     libgomp 

WORKDIR /tmp

RUN curl -OL https://github.com/jasper-software/jasper/archive/version-2.0.32/jasper-2.0.32.tar.gz \
  && tar xzvf jasper-2.0.32.tar.gz \
  && cd  jasper-version-2.0.32 \
  && mkdir BUILD && cd BUILD \
  && cmake -DCMAKE_INSTALL_PREFIX=/usr    \
      -DCMAKE_BUILD_TYPE=Release     \
      -DCMAKE_SKIP_INSTALL_RPATH=YES \
      -DJAS_ENABLE_DOC=NO            \
      -DCMAKE_INSTALL_DOCDIR=/usr/share/doc/jasper-2.0.32 \
      ..  \
  && make \
  && make test \
  && make install

WORKDIR /tmp
RUN wget $PKGSOURCE && \
    lzip -d -c GraphicsMagick-$PKGVER.tar.lz | tar -xvf - && \
    cd GraphicsMagick-$PKGVER && \
    ./configure \
      --build=$CBUILD \
      --host=$CHOST \
      --prefix=/usr \
      --sysconfdir=/etc \
      --enable-magick-compat \
      --mandir=/usr/share/man \
      --infodir=/usr/share/info \
      --localstatedir=/var \
      --enable-shared \
      --disable-static \
      --with-modules \
      --with-threads \
      --with-webp=yes \
      --with-tiff=yes \
      --with-jpeg=yes \
      --with-jp2=yes \
      --with-png=yes \
      --with-xml=yes \
      --with-wmf=yes \
      --with-ttf \
      --with-gs-font-dir=/usr/share/fonts/Type1 \
      --with-quantum-depth=$QUANTUMDEPTH && \
    make && \
    make install && \
    cd /tmp && \
    rm -rf GraphicsMagick-$PKGVER && \
    rm GraphicsMagick-$PKGVER.tar.lz
  

# Cantaloupe
WORKDIR /tmp

RUN apt-get update && apt-get install -y --no-install-recommends maven unzip

RUN curl -OL https://github.com/cantaloupe-project/cantaloupe/archive/refs/heads/release/4.1.zip \
 && mkdir -p /usr/local/ \
 && cd /usr/local \
 && unzip /tmp/4.1.zip && cd cantaloupe-release-4.1 && mvn clean package -DskipTests \ 
 && mv target/cantaloupe-4.1.10-SNAPSHOT.zip /usr/local/ \
 && cd /usr/local \
 && unzip cantaloupe-4.1.10-SNAPSHOT.zip \
 && ln -s cantaloupe-4.1.10-SNAPSHOT cantaloupe \
 && rm -rf /tmp/4.1.zip \
 && rm -rf /usr/local/cantaloupe-4.1.10-SNAPSHOT.zip \
 && rm -rf /usr/local/cantaloupe-release-4.1 \
 && ls /usr/local/cantaloupe/cantaloupe-* \
 && mkdir -p /etc/cantaloupe


ARG user=cantaloupe
ARG home=/home/$user
RUN adduser --home $home $user
RUN chown -R $user $home

# upcoming docker releases: use --chown=cantaloupe
COPY cantaloupe.properties /etc/cantaloupe/cantaloupe.properties 

RUN mkdir -p /var/log/cantaloupe \
 && mkdir -p /var/cache/cantaloupe \
 && chown -R cantaloupe /var/log/cantaloupe \
 && chown -R cantaloupe /var/cache/cantaloupe \
 && chown -R cantaloupe /etc/cantaloupe

ARG XMX=2g
ARG XMS=256m

ENV XMS=${XMS}
ENV XMX=${XMX}

USER $user



VOLUME ["/var/log/cantaloupe", "/var/cache/cantaloupe"]
CMD ["sh", "-c", "java -Dcantaloupe.config=/etc/cantaloupe/cantaloupe.properties -Xms${XMS} -Xmx${XMX} -jar /usr/local/cantaloupe/cantaloupe-4.1.10-SNAPSHOT.war"]

