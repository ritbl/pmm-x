#!/bin/bash
set -o xtrace
set -e

echo "Packing Grafana BE"
cd /build

if ! command -v lz4 &> /dev/null
then
  apt update
  apt install lz4
fi

if [ -d ./deps/grafana/bin/linux-arm64 ]; then
  rm -rf pack-arm64
  mkdir pack-arm64
  cd pack-arm64
  mkdir -p ./usr/sbin
  cp -r ./../deps/grafana/bin/linux-arm64/grafana-server ./usr/sbin/grafana-server

  tar -I 'lz4 --fast' -cf ../x-grafana-be-arm64-$TAG.tar.lz4 ./
fi

if [ -d ./deps/grafana/bin/linux-amd64 ]; then
  rm -rf pack-amd64
  mkdir pack-amd64
  cd pack-amd64
  mkdir -p ./usr/sbin
  cp -r ./../deps/grafana/bin/linux-amd64/grafana-server ./usr/sbin/grafana-server

  tar -I 'lz4 --fast' -cf ../x-grafana-be-amd64-$TAG.tar.lz4 ./
fi
