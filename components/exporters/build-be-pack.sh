#!/bin/bash
set -o xtrace
set -e

export ARCH=`uname -m`
echo "Packing Exporters [$ARCH]"
cd /build


if ! command -v lz4 &> /dev/null
then
  apt update
  apt install lz4
fi

if [[ $ARCH = "aarch64" ]]; then
  rm -rf pack-arm64
  mkdir pack-arm64
  cd pack-arm64
  # -- azure_exporter
  mkdir -p ./usr/local/percona/pmm2/exporters
  cp ./../deps/azure_metrics_exporter/azure_metrics_exporter ./usr/local/percona/pmm2/exporters/azure_exporter
  # -- mongodb_exporter
  cp ./../deps/mongodb_exporter/mongodb_exporter ./usr/local/percona/pmm2/exporters/
  # -- node_exporter
  cp ./../deps/node_exporter/node_exporter ./usr/local/percona/pmm2/exporters/
  # -- postgres_exporter
  cp ./../deps/postgres_exporter/cmd/postgres_exporter/postgres_exporter ./usr/local/percona/pmm2/exporters/
  # -- rds_exporter
  cp ./../deps/rds_exporter/rds_exporter ./usr/local/percona/pmm2/exporters/

  tar -I 'lz4 --fast' -cf ../x-exporters-be-arm64-$TAG.tar.lz4 ./
fi

if [[ $ARCH = "x86_64" ]]; then
  rm -rf pack-amd64
  mkdir pack-amd64
  cd pack-amd64
  # -- azure_exporter
  mkdir -p ./usr/local/percona/pmm2/exporters
  cp ./../deps/azure_metrics_exporter/azure_metrics_exporter ./usr/local/percona/pmm2/exporters/azure_exporter
  # -- mongodb_exporter
  cp ./../deps/mongodb_exporter/mongodb_exporter ./usr/local/percona/pmm2/exporters/
  # -- node_exporter
  cp ./../deps/node_exporter/node_exporter ./usr/local/percona/pmm2/exporters/
  # -- postgres_exporter
  cp ./../deps/postgres_exporter/cmd/postgres_exporter/postgres_exporter ./usr/local/percona/pmm2/exporters/
  # -- rds_exporter
  cp ./../deps/rds_exporter/rds_exporter ./usr/local/percona/pmm2/exporters/

  tar -I 'lz4 --fast' -cf ../x-exporters-be-amd64-$TAG.tar.lz4 ./
fi
