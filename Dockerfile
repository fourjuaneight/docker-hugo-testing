# Use Alpine Linux as our base image so that we minimize the overall size our final container, and minimize the surface area of packages that could be out of date.
FROM alpine:latest

LABEL description="Docker container for building websites with the Hugo static site generator and PostCSS."
LABEL maintainer="Juan Villela <https://www.juanvillela.dev>"

# Config
ENV GLIBC_VER=2.27-r0

# Build dependencies
RUN apk update && apk upgrade
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" > /etc/apk/repositories \
  && echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
  && echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
  && echo "http://dl-cdn.alpinelinux.org/alpine/v3.11/main" >> /etc/apk/repositories \
  apk add --update --no-cache \
  bash \
  ca-certificates \
  chromium \
  curl \
  freetype \
  git \
  harfbuzz \
  libstdc++ \
  nodejs-lts \
  npm \
  nss \
  openssh-client \
  ttf-freefont \
  && rm -rf /var/cache/* \
  && mkdir /var/cache/apk

# Add Chrome as a user
RUN mkdir -p /usr/src/app \
  && adduser -D chrome \
  && chown -R chrome:chrome /usr/src/app
# Run Chrome as non-privileged
USER chrome
WORKDIR /usr/src/app

ENV CHROME_BIN=/usr/bin/chromium-browser \
  CHROME_PATH=/usr/lib/chromium/

# Autorun chrome headless with no GPU
ENTRYPOINT ["chromium-browser", "--headless", "--disable-gpu", "--disable-software-rasterizer", "--disable-dev-shm-usage"]

# Install npm dependencies
# A wildcard is used to ensure both package.json AND package-lock.json are copied where available
COPY package*.json ./
RUN npm install -g

# Install glibc: This is required for HUGO-extended (including SASS) to work.
RUN wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
  && wget "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/$GLIBC_VER/glibc-$GLIBC_VER.apk" \
  && apk --no-cache add "glibc-$GLIBC_VER.apk" \
  && rm "glibc-$GLIBC_VER.apk" \
  && wget "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/$GLIBC_VER/glibc-bin-$GLIBC_VER.apk" \
  && apk --no-cache add "glibc-bin-$GLIBC_VER.apk" \
  && rm "glibc-bin-$GLIBC_VER.apk" \
  && wget "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/$GLIBC_VER/glibc-i18n-$GLIBC_VER.apk" \
  && apk --no-cache add "glibc-i18n-$GLIBC_VER.apk" \
  && rm "glibc-i18n-$GLIBC_VER.apk"

# Install HUGO
RUN TAG_LATEST_URL="$(curl -LsI -o /dev/null -w %{url_effective} https://github.com/gohugoio/hugo/releases/latest)" \
  && echo ${TAG_LATEST_URL} \
  && HUGO_VERSION="$(echo ${TAG_LATEST_URL} | egrep -o '[0-9]+\.[0-9]+\.?[0-9]*')" \
  && echo ${HUGO_VERSION} \
  && wget -qO- "https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_Linux-64bit.tar.gz" | tar xz \
  && mv hugo /usr/local/bin/hugo \
  && chmod +x /usr/local/bin/hugo

RUN hugo version