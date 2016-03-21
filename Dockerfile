FROM creativearea/libvips:8.2.2-0

MAINTAINER CREATIVE AREA <contact@creative-area.net>

RUN apk add --update --virtual build-deps \
	curl \
	make \
	gcc \
	g++ \
	binutils-gold \
	python \
	linux-headers \
	paxctl \
	libgcc \
	libstdc++

ENV NODE_VERSION 5.9.0

WORKDIR /tmp

RUN curl -sOL https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}.tar.gz && \
	tar xzf node-v${NODE_VERSION}.tar.gz \
	cd node-v${NODE_VERSION} && \
	./configure --prefix=/usr && \
	NPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) && \
	make out/Makefile && \
	make -j${NPROC} -C out mksnapshot && \
	paxctl -cm out/Release/mksnapshot && \
	make -j${NPROC} && \
	make install && \
	paxctl -cm /usr/bin/node && \
	rm -rf /etc/ssl /usr/share/man /tmp/* /var/cache/apk/* /root/.npm /root/.node-gyp \
		/usr/lib/node_modules/npm/man /usr/lib/node_modules/npm/doc /usr/lib/node_modules/npm/html
