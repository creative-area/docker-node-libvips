FROM ubuntu:14.04

MAINTAINER CREATIVE AREA <contact@creative-area.net>

# Let the conatiner know that there is no tty
ENV DEBIAN_FRONTEND noninteractive

# Common dependencies
RUN apt-get -q update && apt-get install -y \
	curl \
	unzip \
	git \
	pkg-config \
	automake \
	build-essential

# Libvips dependencies
RUN apt-get install -y \
	gobject-introspection \
	zlib1g-dev \
	gtk-doc-tools \
	libglib2.0-dev \
	libjpeg-turbo8-dev \
	libpng12-dev \
	libwebp-dev \
	libtiff5-dev \
	libexif-dev \
	libxml2-dev \
	swig \
	libmagickwand-dev \
	libpango1.0-dev \
	libmatio-dev \
	libopenslide-dev \
	libgdk-pixbuf2.0-dev \
	libgsf-1-dev \
	liblcms2-dev \
	libmagickcore-dev \
	libsqlite3-dev \
	libcairo2-dev \
	sqlite3 \
	libsqlite3-dev

# Install JRE
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys DA1A4A13543B466853BAF164EB9B1D8886F44E2A \
	&& echo 'deb http://ppa.launchpad.net/openjdk-r/ppa/ubuntu trusty main' > /etc/apt/sources.list.d/openjdk.list

# add a simple script that can auto-detect the appropriate JAVA_HOME value
# based on whether the JDK or only the JRE is installed
RUN { \
		echo '#!/bin/bash'; \
		echo 'set -e'; \
		echo; \
		echo 'dirname "$(dirname "$(readlink -f "$(which javac || which java)")")"'; \
	} > /usr/local/bin/docker-java-home \
	&& chmod +x /usr/local/bin/docker-java-home

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/jre

ENV JAVA_VERSION 8u72
ENV JAVA_UBUNTU_VERSION 8u72-b15-1~trusty1

RUN set -x \
	&& apt-get -q update \
	&& apt-get install -y openjdk-8-jre-headless="$JAVA_UBUNTU_VERSION" \
	&& [ "$JAVA_HOME" = "$(docker-java-home)" ]

RUN /var/lib/dpkg/info/ca-certificates-java.postinst configure

# Install NodeJS
ENV NODE_VERSION 5.x
RUN curl -sL https://deb.nodesource.com/setup_$NODE_VERSION | bash - && apt-get install -y nodejs

# Build libvips
WORKDIR /tmp
ENV LIBVIPS_VERSION_MAJOR 8
ENV LIBVIPS_VERSION_MINOR 2
ENV LIBVIPS_VERSION_PATCH 2
ENV LIBVIPS_VERSION $LIBVIPS_VERSION_MAJOR.$LIBVIPS_VERSION_MINOR.$LIBVIPS_VERSION_PATCH
RUN \
	curl -O http://www.vips.ecs.soton.ac.uk/supported/$LIBVIPS_VERSION_MAJOR.$LIBVIPS_VERSION_MINOR/vips-$LIBVIPS_VERSION.tar.gz && \
	tar zvxf vips-$LIBVIPS_VERSION.tar.gz && \
	cd vips-$LIBVIPS_VERSION && \
	./configure --disable-debug --disable-static --disable-introspection --disable-dependency-tracking --without-python --without-orc --without-fftw $1 && \
	make && \
	make install && \
	ldconfig

# Clean up
WORKDIR /
RUN apt-get autoclean && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
