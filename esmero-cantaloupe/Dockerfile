FROM openjdk:13-alpine3.9

ENV LANG en_US.UTF-8

# JRE fails to load fonts if there are no standard fonts in the image; This breaks Cantaloups /admin endpoint
# see https://github.com/docker-library/openjdk/issues/73#issuecomment-207816707

RUN apk add --update ttf-dejavu && rm -rf /var/cache/apk/*

# Cantaloupe docker starter script
# https://github.com/cantaloupe-project/cantaloupe/releases/tag/v4.1.5
# Build and run: 
# $ sudo docker build -t esmero-cantaloupe .
# $ sudo docker run -d --rm -p 8183:8182 -v ./cantaloupeconfig:/etc/cantaloupe --name esmero-cantaloupe esmero-cantaloupe

# Publish new tag -- PRIVATE
# $docker login (user diegopino) use your own name folks!
# $ docker docker build -t esmero/cantaloupe-s3:4.1.5
# $ docker push esmero/cantaloupe-s3:4.1.5
# See upgrading from 4.0.3 to 4.1.5 https://github.com/cantaloupe-project/cantaloupe/blob/develop/UPGRADING.md#40x--41

ENV CANTALOUPE_VERSION 4.1.5
ENV PKGNAME=graphicsmagick
# 1.3.34 (Released Dec 20, 2019)
ENV PKGVER=1.3.34
# Uses 50% of the memory of 16. Use 16 if dealing with 48/64 bit pixels color
ENV QUANTUMDEPTH=8
ENV PKGSOURCE=http://downloads.sourceforge.net/$PKGNAME/$PKGNAME/$PKGVER/GraphicsMagick-$PKGVER.tar.lz

EXPOSE 8182

RUN apk --update add curl
RUN apk --update add ghostscript ghostscript-dev openjpeg-tools
# Graphicsmagick dependencies
RUN apk add --no-cache --update g++ \
                     gcc \
                     make \
                     automake \
                     autoconf \
                     git \
                     lzip \
                     wget \
                     sdl-dev \
                     giflib-dev \
                     libjpeg-turbo-dev \
                     lcms2-dev \
                     libwmf-dev \
                     jasper-dev \
                     libx11-dev \
                     libpng-dev \
                     libtool \
                     jasper-dev \
                     bzip2-dev \
                     zlib-dev \
                     libxml2-dev \
                     tiff-dev \
                     exiftool \
                     freetype-dev \
                     libgomp 

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
    cd / && \
    rm -rf GraphicsMagick-$PKGVER && \
    rm GraphicsMagick-$PKGVER.tar.lz && \
    apk del g++ \
            gcc \
            make \
            automake \
            autoconf \
            git \
            lzip \
            wget 

RUN adduser -S cantaloupe
RUN apk add --update --no-cache ffmpeg

# Cantaloupe
WORKDIR /tmp
RUN curl -OL https://github.com/medusa-project/cantaloupe/releases/download/v$CANTALOUPE_VERSION/Cantaloupe-$CANTALOUPE_VERSION.zip \
 && mkdir -p /usr/local/ \
 && cd /usr/local \
 && unzip /tmp/Cantaloupe-$CANTALOUPE_VERSION.zip \
 && ln -s cantaloupe-$CANTALOUPE_VERSION cantaloupe \
 && rm -rf /tmp/cantaloupe-$CANTALOUPE_VERSION \
 && rm /tmp/Cantaloupe-$CANTALOUPE_VERSION.zip \
 && mkdir -p /etc/cantaloupe \
 && cp /usr/local/cantaloupe/deps/Linux-x86-64/lib/* /usr/lib/. 
# upcoming docker releases: use --chown=cantaloupe
COPY cantaloupe.properties /etc/cantaloupe/cantaloupe.properties 
RUN mkdir -p /var/log/cantaloupe \
 && mkdir -p /var/cache/cantaloupe \
 && chown -R cantaloupe /var/log/cantaloupe \
 && chown -R cantaloupe /var/cache/cantaloupe \
 && chown -R cantaloupe /etc/cantaloupe

USER cantaloupe 
VOLUME ["/var/log/cantaloupe", "/var/cache/cantaloupe"]
CMD ["sh", "-c", "java -Dcantaloupe.config=/etc/cantaloupe/cantaloupe.properties -Xmx2g -jar /usr/local/cantaloupe/cantaloupe-$CANTALOUPE_VERSION.war"]