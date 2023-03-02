#!/bin/bash
set -o xtrace
set -e

echo "Building Core Backend"
cd /build

# fixes build issue on jetbuild
go env -w GOFLAGS="-buildvcs=false"

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
