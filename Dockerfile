FROM ubuntu:14.04

MAINTAINER CREATIVE AREA <contact@creative-area.net>

# Let the conatiner know that there is no tty
ENV DEBIAN_FRONTEND noninteractive

# Install basics dependencies
RUN apt-get update && apt-get install -y \
	curl \
	unzip \
	pkg-config \
	automake \
	build-essential \
	git

# Install Libvips dependencies
RUN apt-get install -y \
	gobject-introspection \
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
	libgsf-1-dev \
	liblcms2-dev \
	libxml2-dev \
	libmagickcore-dev

# Install NodeJS
ENV NODE_VERSION 0.12
RUN curl -sL https://deb.nodesource.com/setup_$NODE_VERSION | bash - && apt-get install -y nodejs

# Build libvips
WORKDIR /tmp
ENV LIBVIPS_VERSION_MAJOR 7
ENV LIBVIPS_VERSION_MINOR 42
ENV LIBVIPS_VERSION_PATCH 3
ENV LIBVIPS_VERSION $LIBVIPS_VERSION_MAJOR.$LIBVIPS_VERSION_MINOR.$LIBVIPS_VERSION_PATCH
RUN \
  curl -O http://www.vips.ecs.soton.ac.uk/supported/$LIBVIPS_VERSION_MAJOR.$LIBVIPS_VERSION_MINOR/vips-$LIBVIPS_VERSION.tar.gz && \
  tar zvxf vips-$LIBVIPS_VERSION.tar.gz && \
  cd vips-$LIBVIPS_VERSION && \
  ./configure --enable-debug=no --enable-docs=no --enable-cxx=yes --without-python --without-orc --without-fftw --without-gsf $1 && \
  make && \
  make install && \
  ldconfig

# Clean up
WORKDIR /
RUN rm -rf /tmp/* /var/tmp/*