##  Esmero-php FPM 8.0.28 Container

A ready to be used with Archipelago in a docker-compose file with NGINX. Runs a standard PHP 8.0.28 FPM Container with embeded extras.

### Building the image

```docker
docker build -t esmero/php-8.0.28-fpm:1.1.0 .
```

### Configuration and startup

Use with an NGINX Container using fastcgi proxying against this container

### Deployed features

- PHP 8.0.28 with redis extension and D9 Optimizations
- TESSERACT 5.1 with JP2 support and OpenMP (/usr/local/bin/tesseract)
- TESSERACT 4.x with JP2 support and SSE (/usr/bin/tesseract)
- COMPOSER
- DRUSH
- BASH (yes)
- PDFALTO 0.5
- FIDO 1.4 
- Webfonts

#### Multiplatform Build

For reference on `docker buildx` usage see [Docker's Multi-platform images documentation](https://docs.docker.com/build/building/multi-platform/).

```docker
docker buildx create --name m1_builder
docker buildx use m1_builder
docker buildx inspect --bootstrap
docker buildx build --platform linux/amd64,linux/arm64 -t esmero/php-8.0.28-fpm:1.1.0-multiarch . --push
```

To build the debug image for developing, after building and pushing the image above to your repo, update the base image in `Dockerfile.dev` and run the following:

```docker
docker buildx build --platform linux/amd64,linux/arm64 -t esmero/php-8.0.28-fpm:1.1.0-multiarch . --push --file Dockerfile.dev
```

