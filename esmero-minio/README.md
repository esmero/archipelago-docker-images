# Min.io community (no longer maintained) Container

# How to build a multi platform Container?

- Replace `RELEASE` with the Github tag you want. "RELEASE.2022-06-11T19-55-32Z" was the last one with Gateway support.
- Make sure your tag (-t) makes sense
  
```Shell
docker buildx build  --no-cache \                 
  --platform linux/amd64,linux/arm64 --build-arg RELEASE="RELEASE.2022-06-11T19-55-32Z" \
  --push -t esmero/minio:gateway \
  . --file Dockerfile
```
