##  Esmero-cantaloupe IIIF Cantaloupe container

Cantaloupe 4.16 Docker Image with Graphicsmagic, TurboJpeg and ffmpeg processors for the Archipelago Project

### Building the image
```SHELL
$ docker build -t esmero-cantaloupe .
````

### Configuration and startup

Create a new `cantaloupe.properties` file or customize the one provided at `cantaloupeconfig/cantaloupe.properties`
make sure that at least a `-v` argument is passed to the docker run statement with the location of your `cantaloupe.properties` file
mapped to internal /etc/cantaloupe


`-v "$(pwd)/cantaloupeconfig":/etc/cantaloupe`

For full configuration settings and a step by step HOW-TO see https://medusa-project.github.io/cantaloupe/

```SHELL
Sample Docker Run command to expose Cantaloupe to port 8183
$ docker run --rm -d \
 -v /some/path/esmero-cantaloupe/cantaloupeconfig:/etc/cantaloupe \
 -v /some/path/esmero-cantaloupe/cache:/var/cache/cantaloupe \
 -p 8183:8182 --name esmero-cantaloupe esmero-cantaloupe 

````
Test with

http://localhost:8183/iiif/2/32237860_235230863897747_3901188536635752448_n1.jpg/info.json 

A thumbnail

http://localhost:8183/iiif/2/32237860_235230863897747_3901188536635752448_n1.jpg/full/!150,150/0/default.jpg

A Video Frame

http://localhost:8183/iiif/2/esmero_test_video_by_diego.m4v/full/full/0/default.jpg?time=00:00:02


### Deployed features

ffmpeg
GraphicsMagic
pdfbox
TurboJpeg
Kakadu Native processor
S3 enabled
Admin interface is enabled
http://localhost:8183/admin

Allows also ENV to be passed via e.g a docker-compose.yml
Available ones are JavaVM Arguments
XMX: 2gb (default)
XMS: 256m (default)


