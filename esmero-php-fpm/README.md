##  Esmero-php FPM 8.1.x Container

A ready to be used with Archipelago in a docker-compose file with NGINX. Runs a standard PHP 8.1.x FPM Container on Alpine 3.18 with embeded extras.

### Building the image
```SHELL
$ docker build -t esmero/php-8.1-fpm:1.2.0 .
````

### Configuration and startup

Use with an NGINX Container using fastcgi proxying against this container

### Deployed features

- PHP 8.1.x (lasted on build) with redis extension and D10 Optimizations
- TESSERACT 5.1 with JP2 support and OpenMP (/usr/local/bin/tesseract)
- TESSERACT 4.x with JP2 support and SSE (/usr/bin/tesseract)
- COMPOSER
- DRUSH
- BASH (yes)
- PDFALTO 0.5
- FIDO 1.6
- Webfonts
- Image Magic with JP2 support

#### Multiplatform Build

For reference on `docker buildx` usage see [Docker's Multi-platform images documentation](https://docs.docker.com/build/building/multi-platform/).

```docker
docker buildx create --name m1_builder
docker buildx use m1_builder
docker buildx inspect --bootstrap
docker buildx build --platform linux/amd64,linux/arm64 -t esmero/php-8.1-fpm:1.2.0-multiarch . --push
```

To build the debug image for developing, after building and pushing the image above to your repo, update the base image in `Dockerfile.dev` and run the following:

```docker
docker buildx build --platform linux/amd64,linux/arm64 -t esmero/php-8.1-fpm:1.2.0-dev-multiarch . --push --file Dockerfile.dev
```
