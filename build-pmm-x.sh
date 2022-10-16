#!/bin/bash
set -o xtrace
set -e

export ARCH=`uname -m`
echo "Building PMM-X [$ARCH]"

if [[ $ARCH = "aarch64" ]]; then
  wget -c https://pmm-x.s3.eu-central-1.amazonaws.com/x-core-be-arm64-$X_CORE_TAG.tar.lz4 -O - | tar -I "lz4" -xv -C /
  wget -c https://pmm-x.s3.eu-central-1.amazonaws.com/x-exporters-be-arm64-$X_EXPORTERS_TAG.tar.lz4 -O - | tar -I "lz4" -xv -C /
  wget -c https://pmm-x.s3.eu-central-1.amazonaws.com/x-grafana-fe-$X_GRAFANA_TAG.tar.lz4 -O - | tar -I "lz4" -xv -C /
  wget -c https://pmm-x.s3.eu-central-1.amazonaws.com/x-grafana-be-arm64-$X_GRAFANA_TAG.tar.lz4 -O - | tar -I "lz4" -xv -C /
fi

if [[ $ARCH = "x86_64" ]]; then
  wget -c https://pmm-x.s3.eu-central-1.amazonaws.com/x-core-be-amd64-$X_CORE_TAG.tar.lz4 -O - | tar -I "lz4" -xv -C /
  wget -c https://pmm-x.s3.eu-central-1.amazonaws.com/x-exporters-be-amd64-$X_EXPORTERS_TAG.tar.lz4 -O - | tar -I "lz4" -xv -C /
  wget -c https://pmm-x.s3.eu-central-1.amazonaws.com/x-grafana-fe-$X_GRAFANA_TAG.tar.lz4 -O - | tar -I "lz4" -xv -C /
  wget -c https://pmm-x.s3.eu-central-1.amazonaws.com/x-grafana-be-amd64-$X_GRAFANA_TAG.tar.lz4 -O - | tar -I "lz4" -xv -C /
fi
