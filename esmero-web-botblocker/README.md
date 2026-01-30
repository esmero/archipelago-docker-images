##  esmero-web NGINX Certbot Container with bot blocking based on jonasal/nginx-certbot:alpine

This is the nginx-certbot image with a layer for all that's needed by the nginx-ultimate-bad-bot-blocker: https://github.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker

### Building the image

docker buildx create --name m1_builder
docker buildx use m1_builder
docker buildx inspect --bootstrap
docker buildx build --platform linux/amd64,linux/arm64 -t esmero/:esmero/nginx-bot-blocker:1.6.0-multiarch . --push
