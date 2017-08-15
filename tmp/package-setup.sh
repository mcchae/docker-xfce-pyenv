#!/bin/sh

apk add --no-cache --update \
  bash \
  build-base \
  ca-certificates \
  git \
  bzip2-dev \
  linux-headers \
  ncurses-dev \
  openssl \
  openssl-dev \
  readline-dev \
  sqlite-dev

update-ca-certificates

rm -rf /var/cache/apk/*
