FROM ubuntu:14.04

MAINTAINER CREATIVE AREA <contact@creative-area.net>

# Let the conatiner know that there is no tty
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -qq update && apt-get install -y \
	curl \
	unzip \
	pkg-config \
	automake \
	build-essential \
	git \
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

# Install NodeJS
ENV NODE_VERSION 5.x
RUN curl -sL https://deb.nodesource.com/setup_$NODE_VERSION | bash - && apt-get install -y nodejs

# Build libvips
WORKDIR /tmp
ENV LIBVIPS_VERSION_MAJOR 8
ENV LIBVIPS_VERSION_MINOR 1
ENV LIBVIPS_VERSION_PATCH 1
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
