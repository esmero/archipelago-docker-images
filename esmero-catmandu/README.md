##  Esmero-catmandu 1.2003 Container

A ready to be used with Archipelago to harvest or mangle data/OAI and JSON. Runs a Perl CPANM, Catmandu, dependencies and a lot of them on Container based on Alpine.

### Building the image
```SHELL
$ docker build -t esmero/catmandu .
````

### Configuration and startup
WE recommend to moun a local folder into catmandu so you can share outputs, but you can also call directly the commands from outside
Given a folder named `/Users/youuser/catmandu`
```SHELL
$ docker run -v /Users/youuser/catmandu:/home/catmandu -ti esmero/catmandu
````

Or without login into the container 
```SHELL
$ docker run -ti esmero/catmandu bash -c "catmandu convert OAI --url https://lib.ugent.be/oai --metadataPrefix oai_dc --set flandrica --handler oai_dc"
````

To get those lovely records as JSON directly into your screen. Need them in a file?
```SHELL
$ docker run -ti esmero/catmandu bash -c "catmandu convert OAI --url https://lib.ugent.be/oai --metadataPrefix oai_dc --set flandrica --handler oai_dc" > harvest.json
````
Enjoy!

### Deployed features

Latest Native Perl for Alpine
CPANM
NANO
Catmandu 
Catmandu::OAI
XML/SSL/ETC/MARC. All the goodies
BASH (yes)