FROM alpine:3.22 AS audiobuilder
# cant use 3.23 bc VERSION_OGG and cmake are 3.5 <

WORKDIR /build

ENV LIBRARY_PATH=/lib:/usr/lib
ENV LIBVORBIS_LIBRARIES=""
ENV VERSION_AUDIOWAVEFORM="1.7.1"
ENV VERSION_LIBSNDFILE="1.2.0"
ENV VERSION_FLAC="1.3.3"
ENV VERSION_OGG="1.3.5"
ENV VERSION_OPUS="1.4"

RUN apk add --no-cache git make cmake gcc g++ gperf samurai libmad-dev zlib-dev zlib-static libpng-static libpng-dev libgd \
    libid3tag-dev libsndfile-dev gd-dev boost-static boost-dev build-base autoconf automake gettext libtool libvorbis-dev \
    alsa-lib-dev

RUN wget https://github.com/xiph/ogg/archive/refs/tags/v${VERSION_OGG}.tar.gz \
    && tar xzf v${VERSION_OGG}.tar.gz \
    && cd ogg-${VERSION_OGG} \
    && ./autogen.sh \
    && ./configure --enable-shared=no \
    && make -j${nproc} \
    && make install \
    && cd ../ \
    && wget https://github.com/xiph/opus/archive/v${VERSION_OPUS}.tar.gz \
    && tar xzf v${VERSION_OPUS}.tar.gz \
    && cd opus-${VERSION_OPUS} \
    && ./autogen.sh \
    && ./configure --enable-shared=no \
    && make -j${nproc}\
    && make install \
    && cd ../ \
    && wget https://github.com/xiph/flac/archive/${VERSION_FLAC}.tar.gz \
    && tar xzf ${VERSION_FLAC}.tar.gz \
    && cd flac-${VERSION_FLAC} \
    && ./autogen.sh \
    && ./configure --enable-shared=no \
    && make -j${nproc}\
    && make install \
    && cd ../ \
    && git clone https://github.com/xiph/vorbis.git \
    && cd vorbis \
    && ./autogen.sh \
    && ./configure --enable-shared=no \
    && make -j${nproc}\
    && make install \
    && cd ../ \
    && git clone https://codeberg.org/tenacityteam/libid3tag \
    && cd libid3tag \
    && cmake -B build -G Ninja \
      -DBUILD_SHARED_LIBS=OFF \
      -DCMAKE_BUILD_TYPE=MinSizeRel \
      -DENABLE_TESTS=YES \
      -DCMAKE_INSTALL_PREFIX=/usr \
      -DCMAKE_INSTALL_LIBDIR=lib \
    && cmake --build build -j $(nproc) \
    && cd build \
    && CTEST_OUTPUT_ON_FAILURE=TRUE ctest \
    && cd .. \
	  && cmake --install build \
    && wget https://github.com/libsndfile/libsndfile/archive/${VERSION_LIBSNDFILE}.tar.gz \
    && tar xzf ${VERSION_LIBSNDFILE}.tar.gz \
    && cd libsndfile-${VERSION_LIBSNDFILE} \
    && cmake -B build -G Ninja \
      -DBUILD_SHARED_LIBS=OFF \
      -DCMAKE_BUILD_TYPE=MinSizeRel \
      -DCMAKE_INSTALL_PREFIX=/usr \
      -DENABLE_MPEG=ON \
    && cmake --build build -j $(nproc) \
    && cd build \
    && CTEST_OUTPUT_ON_FAILURE=TRUE ctest -E write_read_test_sd2 \
    && cd ../ \
    && cmake --install build \
    && cd /build \
    && wget https://github.com/bbc/audiowaveform/archive/${VERSION_AUDIOWAVEFORM}.tar.gz \
    && tar xzf ${VERSION_AUDIOWAVEFORM}.tar.gz \
    && cd audiowaveform-${VERSION_AUDIOWAVEFORM} \
    && mkdir build \
    && cd build \
    && cmake -D ENABLE_TESTS=0 -D BUILD_STATIC=1 .. \
    && make -j${nproc}\
    && cp audiowaveform* /bin \
    && cd /build \
    && rm -rf /audiowaveform
    
RUN git clone https://github.com/DiegoPino/BWFMetaEdit \
    && cd BWFMetaEdit \
    && git checkout alpine-linux \
    && cd Project/GNU/CLI \
    && autoupdate && ./autogen.sh \
    && ./configure CFLAGS="-static" \
    && make LDFLAGS="--static" \
    && make install \
    && cd /build \
    && rm -rf /BWFMetaEdit
    

FROM php:8.3.31-fpm-alpine3.23
# install the PHP extensions we need
# postgresql-dev is needed for https://bugs.alpinelinux.org/issues/3642

# FONTS?

RUN apk --no-cache add msttcorefonts-installer fontconfig && \
    update-ms-fonts && \
    fc-cache -f
    
# For now not going pdftotree    
#RUN set -eux; \
#    \
#    apk add --update python3-dev \
#		 py3-pip \
#         linux-headers \
#         musl-dev \
#         build-base \
#         hdf5 \
#         hdf5-dev \
#         py3-pip py3-numpy py3-pandas py3-scipy py3-scikit-learn py3-wheel py3-pillow jpeg-dev zlib-dev
#RUN set -eux; pip install --no-cache-dir --no-binary :all: tables h5py 
#RUN set -eux; pip install pdftotree
        
RUN set -eux; \
	\
	apk add --no-cache --virtual .build-deps \
		coreutils \
        zlib-dev \
		libxml2-dev \
		libxslt-dev \
		freetype-dev \
		libjpeg-turbo-dev \
		libpng-dev \
        # zlib \
		libzip-dev \
		postgresql-dev \
		php83-dev \
		# Equivalent of build essentials
		alpine-sdk \
        pcre-dev \
        $PHPIZE_DEPS \
		imagemagick \
		imagemagick-libs \
		imagemagick-dev \
                icu-dev \
	; \
	\
	docker-php-ext-configure gd \
		--with-freetype=/usr/include \
		--with-jpeg=/usr/include \
	; \
	\
        docker-php-ext-configure intl; \
        \
	docker-php-ext-install -j "$(nproc)" \
		gd \
		zip \
		pdo_mysql \
		mysqli \
		xsl \
		opcache \
		exif \
		pcntl \
		pgsql \
		pdo_pgsql \
		bcmath \
		intl \
	; \
	\
	runDeps="$( \
		scanelf --needed --nobanner --format '%n#p' --recursive /usr/local \
			| tr ',' '\n' \
			| sort -u \
			| awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
	)"; \
	pecl install imagick; \
        pecl install apcu; \
        pecl install redis; \
	\
	apk add --virtual .drupal-phpexts-rundeps $runDeps; \
	docker-php-ext-enable imagick; \
        docker-php-ext-enable apcu; \
        docker-php-ext-enable pcntl; \
        docker-php-ext-enable redis.so; \
        docker-php-ext-enable intl; \
        apk del .build-deps

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=60'; \
		echo 'opcache.fast_shutdown=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini

RUN { \
		echo 'upload_max_filesize = 512M'; \
		echo 'zend.enable_gc = On'; \
		echo 'post_max_size = 513M'; \
		echo 'memory_limit = 512M'; \
		echo 'max_execution_time = 300'; \
		echo 'log_errors = On'; \
		echo 'error_log = /proc/self/fd/2'; \
	} > /usr/local/etc/php/conf.d/archipelagod10-recommended.ini

RUN { \
		echo 'php_admin_value[error_log] = /proc/self/fd/2'; \
		echo 'php_admin_flag[log_errors] = on'; \
		echo 'catch_workers_output = yes'; \
	} >> /usr/local/etc/php-fpm.d/www.conf

RUN { \
		echo 'upload_max_filesize = 512M'; \
    echo 'zend.enable_gc = On'; \
		echo 'post_max_size = 513M'; \
		echo 'memory_limit = -1'; \
		echo 'max_execution_time = 600'; \
		echo 'log_errors = On'; \
		echo 'error_log = /proc/self/fd/2'; \
	} > /usr/local/etc/php/php-cli.ini
	
    
# Tools we want to keep
RUN apk -U add --no-cache \
		bash \
		patch \
		git openssh \
		wget \
		imagemagick \
		mysql-client \
		file \
		curl \
		nano \
        libxml2 \
		ghostscript \
		poppler-utils \
		python3 \
        xpdf \
        freetype \
	    ffmpeg \
        icu-libs \
		tesseract-ocr-data-ita \
		tesseract-ocr-data-spa \
        tesseract-ocr-data-deu \
        tesseract-ocr-data-tam \
        tesseract-ocr-data-por \
        tesseract-ocr-data-hin \
        tesseract-ocr-data-eng \
        mediainfo \
		exiftool \
		py3-setuptools \
        py-pip \
		&& \
		rm -rf /var/lib/apt/lists/* && \
		rm /var/cache/apk/*

WORKDIR /usr/local/src

# Detect architecture for Tesseract 5
RUN set -eux; \
ARCH="$(uname -m)"; \
case "${ARCH}" in \
   aarch64|arm64) \
     musl='aarch64-alpine-linux-musl'; \
     ;; \
   amd64|x86_64) \
     musl='x86_64-alpine-linux-musl'; \
     ;; \
   *) \
     echo "Unsupported arch: ${ARCH}"; \
     exit 1; \
     ;; \
esac;

# Build Tesseract 5
RUN apk update && apk add --no-cache --virtual .build-deps-tesseract \
       gcc \
       g++ \
       make \
       automake \
       autoconf \
       musl \
       libc-dev \
       libtool \
       alpine-sdk \
       pkgconfig \
       clang \
       clang-dev \
       libtool \
       leptonica-dev \
       openjpeg-dev \
       tiff-dev \
       libpng-dev \
       zlib-dev \
       libgcc \
       mupdf-dev \
       jbig2dec-dev \
       freetype-dev \
       openblas-dev \
       ffmpeg-dev \
       icu-dev \
       git \
       linux-headers && \
       git clone --depth 1 https://github.com/danbloomberg/leptonica.git && cd leptonica && ./autogen.sh && ./configure --build=${musl} --host=${musl} && make && make install && cd ..;\
       git clone --depth 1 https://github.com/tesseract-ocr/tesseract.git && cd tesseract && ./autogen.sh; \
   ./configure --build=${musl} --host=${musl} ;\
   make && make install && ldconfig ;\
   apk del .build-deps-tesseract;

RUN pwd; uname -a;

# Build PDF Alto 0.6

WORKDIR /usr/src
RUN set -eux; \
\
apk update && apk add --no-cache --virtual .build-deps-pdfalto \
     git \
     musl \
     musl-dev \
     g++ gcc clang clang-dev clang-extra-tools clang-libs \
     libgcc \
     tiff-dev \
     libc-dev \
     linux-headers \
     glib \
     pkgconfig \
     glib-dev \
     autoconf automake libtool build-base alpine-sdk cmake make \
     icu-static libxml2-static zlib-static libpng-static freetype-static libxml2-dev icu-dev  zlib-dev libpng-dev  freetype-dev fontconfig-dev xz-dev xz-static brotli-dev brotli-static bzip2-dev bzip2-static && \
     git clone https://github.com/DiegoPino/pdfalto && cd pdfalto && git checkout alpine-3.2 && git submodule update --init --recursive &&\
     cmake . && make && cp pdfalto /usr/bin/pdfalto; \
     apk del .build-deps-pdfalto;
    

RUN apk add gnu-libiconv libheif --update-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/community/ --allow-untrusted
ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php

WORKDIR /usr/src/
# Installation of Composer
RUN cd /usr/src && curl -sS http://getcomposer.org/installer | php
RUN cd /usr/src && mv composer.phar /usr/bin/composer && composer self-update && composer self-update --2

WORKDIR /usr/bin/
# Installation of a custom drush symlink/wrapper, drush launcher is deprecate/archived and won't work with drush 12 / Drush will be installed via composer later
RUN wget -O drush.sh https://raw.githubusercontent.com/esmero/archipelago-docker-images/1.6.0/esmero-php-fpm/tools/drush.sh
RUN chmod +x drush.sh && mv drush.sh drush

#Install WACZ and Fido
WORKDIR /usr/src/
# This is a keeper. Fido needs it. No longer a default in this alpine
RUN apk update && apk add py3-six
RUN set -eux; \
\
        apk update && apk add --no-cache --virtual .build-deps-py \
         gcc \
         python3-dev \
         py3-pip \
         py3-wheel \
         py3-setuptools\
         py3-six \
         linux-headers \
         musl-dev \
         && \
		 python3 -m venv .venv && \
		 source .venv/bin/activate && \
		 python -m pip install --upgrade pip setuptools wheel && \
		 cd /usr/src &&\
		 pwd && \
		 python3 -m pip install opf-fido &&\
		 # Copy from virtual env to /usr/bin
		 cp /usr/src/.venv/bin/fido /usr/bin/fido && \
		 # Using my never ending clone of stuff that is not actively maintained?
         git clone https://github.com/DiegoPino/py-wacz /usr/src/wacz && \
         cd /usr/src/wacz/ && git checkout py-3.12 && \
         python3 -m pip install -r requirements.txt && chmod 755 setup.py && ./setup.py install && \
         # Copy from virtual env to /usr/bin
		 cp /usr/src/.venv/bin/wacz /usr/bin/wacz && \
		 deactivate;

# Build Image Magick with JP2 Support
RUN set -eux; \
        apk update && apk add --no-cache --virtual .build-deps-imagemagick \
           openjpeg-dev \
           openjpeg-tools \
           chrpath \
           fontconfig-dev \
           freetype-dev \
           ghostscript-dev \
           lcms2-dev \
           libheif-dev \
           libjpeg-turbo-dev \
           libpng-dev \
           libtool \
           libwebp-dev \
           libx11-dev \
           libxext-dev \
           libxml2-dev \
           perl-dev \
           tiff-dev \
           zlib-dev \
           libraw-dev \
           make \
           openexr-dev \
           libwmf-dev \
           libltdl \
           graphviz-dev \
           bzip2-dev \
           pango-dev \
           libzip-dev \
           alpine-sdk \
           linux-headers \
           musl-dev \
           && cd /usr/local/src/ \
           && wget https://download.imagemagick.org/ImageMagick/download/ImageMagick-7.1.2-13.tar.gz \
           && tar xzvf ImageMagick-7.1.2-13.tar.gz && rm ImageMagick-7.1.2-13.tar.gz && cd ImageMagick-7.1.2-13 && \
            ./configure --prefix=/usr \
            --sysconfdir=/etc \
            --mandir=/usr/share/man \
            --infodir=/usr/share/info \
            --enable-static \
            --disable-openmp \
            --with-threads \
            --with-openjp2=yes \
            --with-x \
            --with-tiff \
            --with-png \
            --with-webp \
           --with-gslib \
           --with-gs-font-dir=/usr/share/fonts/Type1 \
           --with-heic \
           --with-modules \
           --with-xml \
           --with-perl \
           --with-perl-options="PREFIX=/usr INSTALLDIRS=vendor" \
           && make && make install; \
           apk del .build-deps-imagemagick;

COPY --from=audiobuilder /bin/audiowaveform /usr/bin/audiowaveform
COPY --from=audiobuilder /usr/local/bin/bwfmetaedit /usr/bin/bwfmetaedit

RUN chmod +x /usr/bin/audiowaveform \
  && chmod +x /usr/bin/bwfmetaedit \
  && apk --no-cache add gcc zlib-static libpng-static boost-static \
  && /usr/bin/audiowaveform --version \
  && /usr/bin/bwfmetaedit --version


#Clean up sources, we need to keep drush one
RUN rm -rf /usr/src/wacz
RUN rm -rf /usr/local/src/ImageMagick-7.1.2-13
RUN rm -rf /usr/local/src/tesseract
RUN rm -rf /usr/src/pdfalto
RUN rm -rf /usr/src/xpdf

# For some reason 127.0.0.1 is not working to bind to the Docker Network. But 0.0.0.0 Works
RUN sed -i 's/listen = 127.0.0.1:9000/listen = 0.0.0.0:9000/g' /usr/local/etc/php-fpm.d/www.conf

# Change to bash since our folks like bash
SHELL ["/bin/bash", "-c"]
WORKDIR /var/www/html
VOLUME ["/var/www/html"]
