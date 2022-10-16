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
  mkdir -p ./usr/sbin
  # dbaas-controller
  cp ./../deps/dbaas-controller/bin/dbaas-controller ./usr/sbin/dbaas-controller
  # qan
  cp ./../deps/qan-api2/bin/qan-api2 ./usr/sbin/percona-qan-api2
  # pmm
  # -- pmm-managed
  cp ./../deps/pmm/bin/pmm-managed ./usr/sbin/pmm-managed
  # -- pmm-agent
  cp ./../deps/pmm/bin/pmm-agent  ./usr/sbin/pmm-agent
  # -- pmm-admin
  cp ./../deps/pmm/bin/pmm-admin  ./usr/sbin/pmm-admin
  cd ..

  tar -I 'lz4 --fast' -cf x-core-be-arm64-$TAG.tar.lz4 ./pack-arm64/
fi

if [[ $ARCH = "x86_64" ]]; then
  rm -rf pack-amd64
  mkdir pack-amd64
  cd pack-amd64
  mkdir -p ./usr/sbin
  # dbaas-controller
  cp ./../deps/dbaas-controller/bin/dbaas-controller ./usr/sbin/dbaas-controller
  # qan
  cp ./../deps/qan-api2/bin/qan-api2 ./usr/sbin/percona-qan-api2
  # pmm
  # -- pmm-managed
  cp ./../deps/pmm/bin/pmm-managed ./usr/sbin/pmm-managed
  # -- pmm-agent
  cp ./../deps/pmm/bin/pmm-agent  ./usr/sbin/pmm-agent
  # -- pmm-admin
  cp ./../deps/pmm/bin/pmm-admin  ./usr/sbin/pmm-admin
  cd ..

  tar -I 'lz4 --fast' -cf ../x-core-be-amd64-$TAG.tar.lz4 ./pack-amd64/
fi
