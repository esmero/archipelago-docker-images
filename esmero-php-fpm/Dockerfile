# from https://www.drupal.org/docs/8/system-requirements/drupal-8-php-requirements
FROM php:7.3-fpm-alpine

# install the PHP extensions we need
# postgresql-dev is needed for https://bugs.alpinelinux.org/issues/3642
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
		libzip-dev \
		postgresql-dev \
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
	apk add --virtual .drupal-phpexts-rundeps $runDeps; \
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

# Tools we want to keep
RUN apk -U add --no-cache \
		bash \
		git openssh \
		wget \
		imagemagick \
		mysql-client \
		file \
#		openjdk8-jre \
		curl \
		nano \
		ghostscript \
		tesseract-ocr \
		tesseract-ocr-data-ita \
		tesseract-ocr-data-spa \
		&& \
		rm -rf /var/lib/apt/lists/* && \
		rm /var/cache/apk/*

# Installation of Composer
RUN cd /usr/src && curl -sS http://getcomposer.org/installer | php
RUN cd /usr/src && mv composer.phar /usr/bin/composer

# Installation of drush
RUN git clone https://github.com/drush-ops/drush.git /usr/local/src/drush 
RUN cd /usr/local/src/drush && git checkout 9.1.0
RUN ln -s /usr/local/src/drush/drush /usr/bin/drush
RUN cd /usr/local/src/drush && composer update && composer install
RUN cd /usr/src && curl https://drupalconsole.com/installer -L -o drupal.phar && mv drupal.phar /usr/local/bin/drupal

# Install Droid from nationalarchives.uk
#RUN set -eux; \
#	curl -o 'https://github.com/digital-preservation/droid/zipball/master' /tmp/droid.zip && tar xzf /tmp/droid.zip /usr/local/droid && rm /tmp/droid.zip

# Change to bash since our folks like bash
SHELL ["/bin/bash", "-c"]
WORKDIR /var/www/html
VOLUME ["/var/www/html"]
# https://www.drupal.org/node/3060/release
# ENV DRUPAL_VERSION 8.7.5
# ENV DRUPAL_MD5 39cc326d9db1b4acce9b8716193189fd
# RUN set -eux; \
#	curl -fSL "https://ftp.drupal.org/files/projects/drupal-${DRUPAL_VERSION}.tar.gz" -o drupal.tar.gz; \
#	echo "${DRUPAL_MD5} *drupal.tar.gz" | md5sum -c -; \
#	tar -xz --strip-components=1 -f drupal.tar.gz; \
#	rm drupal.tar.gz; \
#	chown -R www-data:www-data sites modules themes

# vim:set ft=dockerfile: