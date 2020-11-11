# from https://www.drupal.org/docs/8/system-requirements/drupal-8-php-requirements
FROM php:7.3-fpm-alpine

# install the PHP extensions we need
# postgresql-dev is needed for https://bugs.alpinelinux.org/issues/3642
RUN set -eux; \
	\
	apk add --no-cache --virtual .build-deps \
		coreutils \
                zlib-dev \
		patch \
		libxml2-dev \
		libxslt-dev \
		freetype-dev \
		libjpeg-turbo-dev \
		libpng-dev \
		libzip-dev \
		postgresql-dev \
		php7-dev \
		# Equivalent of build essentials
		alpine-sdk \
		imagemagick \
		imagemagick-libs \
		imagemagick-dev \
	; \
	\
	docker-php-ext-configure gd \
		--with-freetype-dir=/usr/include \
		--with-jpeg-dir=/usr/include \
		--with-png-dir=/usr/include \
	; \
	\
	docker-php-ext-install -j "$(nproc)" \
		gd \
		zip \
		pdo_mysql \
		mysqli \
		xsl \
		opcache \
		exif \
		pgsql \
		pdo_pgsql \
		bcmath \
	; \
	\
	runDeps="$( \
		scanelf --needed --nobanner --format '%n#p' --recursive /usr/local \
			| tr ',' '\n' \
			| sort -u \
			| awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
	)"; \
	pecl install imagick; \
	\
	apk add --virtual .drupal-phpexts-rundeps $runDeps; \
	docker-php-ext-enable --ini-name 20-imagick.ini imagick; \
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
    		echo 'zend.enable_gc = On;' \
		echo 'post_max_size = 513M'; \
		echo 'memory_limit = 512M'; \
		echo 'max_execution_time = 300'; \
		echo 'log_errors = On'; \
		echo 'error_log = /proc/self/fd/2'; \
	} > /usr/local/etc/php/conf.d/archipelagod8-recommended.ini

RUN { \
		echo 'php_admin_value[error_log] = /proc/self/fd/2'; \
		echo 'php_admin_flag[log_errors] = on'; \
		echo 'catch_workers_output = yes'; \
	} >> /usr/local/etc/php-fpm.d/www.conf

RUN { \
		echo 'upload_max_filesize = 512M'; \
    		echo 'zend.enable_gc = On;' \
		echo 'post_max_size = 513M'; \
		echo 'memory_limit = -1'; \
		echo 'max_execution_time = 600'; \
		echo 'log_errors = On'; \
		echo 'error_log = /proc/self/fd/2'; \
	} > /usr/local/etc/php/php-cli.ini
	

# Tools we want to keep
RUN apk -U add --no-cache \
		bash \
		git openssh \
		wget \
		imagemagick \
		mysql-client \
		file \
		curl \
		nano \
		ghostscript \
		poppler-utils \
		python3 \
		tesseract-ocr \
		tesseract-ocr-data-ita \
		tesseract-ocr-data-spa \
		exiftool \
		&& \
		rm -rf /var/lib/apt/lists/* && \
		rm /var/cache/apk/*

RUN apk add gnu-libiconv --update-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/community/ --allow-untrusted
ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php

# Installation of Composer
RUN cd /usr/src && curl -sS http://getcomposer.org/installer | php
RUN cd /usr/src && mv composer.phar /usr/bin/composer

# Installation of drush
RUN git clone https://github.com/drush-ops/drush.git /usr/local/src/drush 
RUN cd /usr/local/src/drush && git checkout 10.3.6
RUN ln -s /usr/local/src/drush/drush /usr/bin/drush
RUN cd /usr/local/src/drush && composer update && composer install
RUN cd /usr/src && curl https://drupalconsole.com/installer -L -o drupal.phar && mv drupal.phar /usr/local/bin/drupal

# Install Fido 
RUN cd /usr/src && wget https://github.com/openpreserve/fido/archive/v1.4.0.zip && unzip v1.4.0.zip \
		&& ln -s /usr/bin/python3 /usr/bin/python
RUN cd /usr/src/fido-1.4.0 && ./setup.py install

# Install WACZ

RUN git clone https://github.com/webrecorder/wacz-format.git /usr/local/src/wacz
RUN cd /usr/local/src/wacz/ && git checkout master
RUN cd /usr/local/src/wacz/py-wacz && pip3 install -r requirements.txt && ./setup.py install

#Clean up sources
RUN rm -rf /usr/local/src/*

# Change to bash since our folks like bash
SHELL ["/bin/bash", "-c"]
WORKDIR /var/www/html
VOLUME ["/var/www/html"]
