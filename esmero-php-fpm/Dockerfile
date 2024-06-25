# from https://www.drupal.org/node/3264830

FROM php:8.3.8-fpm-alpine
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
		ffmpeg \
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
	mkdir -p /usr/src/php/ext/imagick; \
	    # Locking on specific commit hash to provide consistent results, at the moment of writing this is the HEAD of master
	    curl -fsSL https://github.com/Imagick/imagick/archive/28f27044e435a2b203e32675e942eb8de620ee58.tar.gz | tar xvz -C "/usr/src/php/ext/imagick" --strip 1; \
	    docker-php-ext-install imagick; \
	# See https://github.com/Imagick/imagick/issues/640. Issue with PHP 8.3 so does not work until an official fix is tagged
	mkdir -p /usr/src/php/ext/apcu && curl -fsSL https://pecl.php.net/get/apcu | tar xvz -C "/usr/src/php/ext/apcu" --strip 1; \
	    docker-php-ext-install apcu; \
	mkdir -p /usr/src/php/ext/redis && curl -fsSL https://pecl.php.net/get/redis | tar xvz -C "/usr/src/php/ext/redis" --strip 1; \
	    docker-php-ext-install redis; \	
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
        icu-libs \
		tesseract-ocr-data-eng \
		tesseract-ocr-data-ita \
		tesseract-ocr-data-spa \
        tesseract-ocr-data-deu \
        tesseract-ocr-data-tam \
        tesseract-ocr-data-por \
        tesseract-ocr-data-hin \
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

# Build PDF Alto
WORKDIR /usr/src
RUN git clone --depth 1 https://github.com/diegopino/pdfalto.git -b alpine
RUN git clone https://github.com/diegopino/xpdf-4.03.git -b alpine && cp -rpv xpdf-4.03 /usr/src/pdfalto/.

WORKDIR /usr/src/pdfalto
RUN set -eux; \
\
apk update && apk add --no-cache --virtual .build-deps-pdfalto \
     git \
     cmake \
     make \
     musl \
     musl-dev \
     g++ gcc clang clang-dev clang-extra-tools clang-libs \
     libpng-dev \
     icu-libs \
     icu-dev \
     libgcc \
     tiff-dev \
     freetype-dev \
     libc-dev \
     linux-headers \
     libxml2-dev \
     glib \
     pkgconfig \
     glib-dev && \
     cd /usr/src/pdfalto/libs/image/png/src && cmake "-DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=true" . && make && \
     cp /usr/src/pdfalto/libs/image/png/src/libpng.a /usr/src/pdfalto/libs/image/png/linux/64/ && \
     cd /usr/src/pdfalto && cmake . && make && make install && cp pdfalto /usr/bin/pdfalto; \
     apk del .build-deps-pdfalto;
    

# RUN apk add gnu-libiconv --update-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/community/ --allow-untrusted
# ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php

WORKDIR /usr/src/
# Installation of Composer
RUN cd /usr/src && curl -sS http://getcomposer.org/installer | php
RUN cd /usr/src && mv composer.phar /usr/bin/composer && composer self-update && composer self-update --2

WORKDIR /usr/bin/
# Installation of a custom drush symlink/wrapper, drush launcher is deprecate/archived and won't work with drush 12 / Drush will be installed via composer later
RUN wget -O drush.sh https://raw.githubusercontent.com/esmero/archipelago-docker-images/1.2.0/esmero-php-fpm/tools/drush.sh
RUN chmod +x drush.sh && mv drush.sh drush


# Install Fido 
#RUN cd /usr/src && wget https://github.com/openpreserve/fido/archive/v1.6.1.zip && unzip v1.6.1.zip \
#		&& pip3 install wheel 
#RUN cd /usr/src/fido-1.6.1 && ./setup.py install

# Install WACZ
RUN set -eux; \
\
        apk update && apk add --no-cache --virtual .build-deps-py \
         gcc \
         python3-dev \
         py3-pip \
         py3-wheel \
         py3-setuptools\
         linux-headers \
         musl-dev \
         && \
         wget https://github.com/openpreserve/fido/archive/v1.6.1.zip && \
         unzip v1.6.1.zip -d /usr/src/ && \
         cd /usr/src/fido-1.6.1 && chmod 755 setup.py && ./setup.py install &&\
         git clone https://github.com/webrecorder/py-wacz /usr/src/wacz && \
         cd /usr/src/wacz/ && git checkout main && \
		 python3 -m venv .venv && \
		 source .venv/bin/activate && \
		 python3 -m pip install setuptools && \
         python3 -m pip install -r requirements.txt --ignore-installed packaging && chmod 755 setup.py && ./setup.py install

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
           && wget https://download.imagemagick.org/ImageMagick/download/ImageMagick-7.1.0-31.tar.gz \
           && tar xzvf ImageMagick-7.1.0-31.tar.gz && rm ImageMagick-7.1.0-31.tar.gz && cd ImageMagick-7.1.0-31 && \
            ./configure --prefix=/usr \
            --sysconfdir=/etc \
            --mandir=/usr/share/man \
            --infodir=/usr/share/info \
            --enable-static \
            --disable-openmp \
            --with-threads \
            --with-openjp2 \
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

#Clean up sources, we need to keep drush one
RUN rm -rf /usr/src/wacz
RUN rm -rf /usr/src/fido-1.6.1
RUN rm -rf /usr/local/src/ImageMagick-7.1.0-31
RUN rm -rf /usr/local/src/tesseract
RUN rm -rf /usr/src/pdfalto
RUN rm -rf /usr/src/xpdf

# Change to bash since our folks like bash
SHELL ["/bin/bash", "-c"]
WORKDIR /var/www/html
VOLUME ["/var/www/html"]
