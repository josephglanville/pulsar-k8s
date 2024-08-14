Pulsar k8s demo
===============

Sets up Pulsar w/TLS and token authentication along with an example CDC connector using k8s managed secrets for the Pulsar source.
This is entirely setup using k8s operators so the entire state is declaratively managed.

## Requirements
- docker
- helm
- kind
- kubectx

## Running

First build the image, this is needed to work around: https://github.com/datastax/kaap/issues/177
```bash
$ docker buildx build -t apachepulsar/pulsar-jpg:3.3.1 - < Dockerfile
```

Then just run `up.sh` to bootstrap the cluster using `kind`
```
$ ./up.sh
```
