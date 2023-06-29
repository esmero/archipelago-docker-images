##  Esmero-php FPM 8.0.16 Container

A ready to be used with Archipelago in a docker-compose file with NGINX. Runs a standard PHP 8.0.16 FPM Container with embeded extras.

### Building the image
```SHELL
$ docker build -t esmero/php-8.0-fpm:1.0.0 .
````

### Configuration and startup

Use with an NGINX Container using fastcgi proxying against this container

### Deployed features

- PHP 8.0.16 with redis extension and D9 Optimizations
- TESSERACT 5.1 with JP2 support and OpenMP (/usr/local/bin/tesseract)
- TESSERACT 4.x with JP2 support and SSE (/usr/bin/tesseract)
- COMPOSER
- DRUSH
- BASH (yes)
- PDFALTO 0.5
- FIDO 1.4 
- Webfonts

#### Multiplaform Build

docker buildx create --name m1_builder
docker buildx use m1_builder
docker buildx inspect --bootstrap
docker buildx build --platform linux/amd64,linux/arm64 -t esmero/php-8.0-fpm:1.0.0-multiarch . --push
