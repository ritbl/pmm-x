#!/bin/bash
set -o xtrace

echo "Packing Grafana BE"
cd /build

if ! command -v lz4 &> /dev/null
then
  apt update
  apt install lz4
fi

if [ -d ./deps/grafana/bin/linux-arm64 ]; then
  mkdir pack-arm64
  cd pack-arm64
  mkdir -p ./usr/sbin
  cp -r ./../deps/grafana/bin/linux-arm64/grafana-server ./usr/sbin/grafana-server
  cd ..

  tar -I 'lz4 --fast' -cf x-grafana-be-arm64-$TAG.tar.lz4 pack-arm64/
fi