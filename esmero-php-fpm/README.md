##  Esmero-php FPM 7.4.9 Container

A ready to be used with Archipelago in a docker-compose file with NGINX . Runs a standard PHP 7.3 FPM Container with some embeded extras.

### Building the image
```SHELL
$ docker build -t esmero/php-7.4-fpm:1.0.0-RC1 .
````

### Configuration and startup

Use with an NGINX Container using fastcgi proxying against this container

### Deployed features

PHP 7.4 with OPCACHE and D8/D9 Optimizations
TESSERACT
COMPOSER
DRUSH
BASH (yes)
