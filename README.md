# Docker Node + Libvips

This docker image provides **NodeJS** and **[Libvips](https://github.com/jcupitt/libvips)**

```bash
$ docker pull creativearea/node-libvips
```

## Usage

If your are using this image, chances are your Node.js project requires native addon modules that depends on LibVips.

As `node-gyp` depends on Python, make, and a proper C/C++ compiler, don't forget to install the correct dependencies in your own Dockerfile. 

```
FROM creativearea/node-libvips

RUN apt-get update && apt-get install -y python g++

RUN mkdir -p /usr/src/app

COPY . /usr/src/app

WORKDIR /usr/src/app

RUN npm install

EXPOSE 80

CMD [ "node", "index.js" ]
```
