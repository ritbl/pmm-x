#!/bin/bash
set -o xtrace
set -e

echo "Building Exporters Backend"
cd /build

cd ./deps/pmm
make init release
cd -

# dbaas-controller
cd ./deps/dbaas-controller
make release
cd -

# qan-api2
cd ./deps/qan-api2
make release
