# from https://www.drupal.org/docs/9/system-requirements/drupal-9-php-requirements
FROM php:8.1.10-fpm-alpine3.15
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
		php8-dev \
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
	} > /usr/local/etc/php/conf.d/archipelagod9-recommended.ini

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
    

RUN apk add gnu-libiconv --update-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/community/ --allow-untrusted
ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php

WORKDIR /usr/src/
# Installation of Composer
RUN cd /usr/src && curl -sS http://getcomposer.org/installer | php
RUN cd /usr/src && mv composer.phar /usr/bin/composer && composer self-update && composer self-update --2

WORKDIR /usr/bin/
# Installation of drush launcher / Drush will be installed via composer later
RUN wget -O drush.phar https://github.com/drush-ops/drush-launcher/releases/latest/download/drush.phar
RUN chmod +x drush.phar && mv drush.phar drush

# Install Fido 
RUN cd /usr/src && wget https://github.com/openpreserve/fido/archive/v1.4.1.zip && unzip v1.4.1.zip \
		&& ln -s /usr/bin/python3 /usr/bin/python && pip install wheel
RUN cd /usr/src/fido-1.4.1 && ./setup.py install && yes | fido-update-signatures

# Install WACZ
RUN set -eux; \
\
        apk update && apk add --no-cache --virtual .build-deps-py \
                 gcc \
		 python3-dev \
		 py3-pip \
                 linux-headers \
                 musl-dev \
                 && \
		 git clone https://github.com/webrecorder/py-wacz /usr/local/src/wacz && \
                 cd /usr/local/src/wacz/ && git checkout main && \
                 pip3 install -r requirements.txt && chmod 755 setup.py && ./setup.py install

# Build Image Magick with JP2 Support
RUN set -eux; \
        apk update && apk add --no-cache --virtual .build-deps-imagemagick \
           openjpeg-dev \
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
RUN rm -rf /usr/local/src/wacz
RUN rm -rf /usr/local/src/ImageMagick-7.1.0-31
RUN rm -rf /usr/local/src/tesseract
RUN rm -rf /usr/src/pdfalto
RUN rm -rf /usr/src/xpdf

# Change to bash since our folks like bash
SHELL ["/bin/bash", "-c"]
WORKDIR /var/www/html
VOLUME ["/var/www/html"]
