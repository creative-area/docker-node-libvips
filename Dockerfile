FROM creativearea/libvips:8.2.2-0

MAINTAINER CREATIVE AREA <contact@creative-area.net>

RUN apk add --no-cache --virtual build-deps \
	curl \
	make \
	gcc \
	g++ \
	binutils-gold \
	python \
	linux-headers \
	paxctl \
	libgcc \
	libstdc++ \
	gnupg

# gpg keys listed at https://github.com/nodejs/node
RUN set -ex \
	&& for key in \
		9554F04D7259F04124DE6B476D5A82AC7E37093B \
		94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
		0034A06D9D9B0064CE8ADF6BF1747F4AD2306D93 \
		FD3A5288F042B6850C66B31F09FE44734EB7990E \
		71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
		DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
		C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
		B9AE9905FFD7803F25714661B63B535A4C206CA9 \
	; do \
		gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
	done

# Install NodeJS
ENV NODE_VERSION=5.9.0 NPM_VERSION=3

WORKDIR /tmp

RUN curl -sOL https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}.tar.gz && \
	curl -sOL https://nodejs.org/dist/v${NODE_VERSION}/SHASUMS256.txt.asc && \
	gpg --verify SHASUMS256.txt.asc && \
	grep node-v${NODE_VERSION}.tar.gz SHASUMS256.txt.asc | sha256sum -c - && \
	tar -zxf node-v${NODE_VERSION}.tar.gz && \
	cd node-v${NODE_VERSION} && \
	./configure --prefix=/usr && \
	make -j$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) && \
	make install && \
	paxctl -cm /usr/bin/node && \
	cd / && \
	if [ -x /usr/bin/npm ]; then \
		npm install -g npm@${NPM_VERSION} && \
		find /usr/lib/node_modules/npm -name test -o -name .bin -type d | xargs rm -rf; \
	fi

RUN	rm -rf /etc/ssl /tmp/* /usr/share/man /tmp/* /var/cache/apk/* /root/.npm /root/.node-gyp /root/.gnupg \
		/usr/lib/node_modules/npm/man /usr/lib/node_modules/npm/doc /usr/lib/node_modules/npm/html
