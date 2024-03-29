#!/bin/bash
set -o xtrace
set -e

echo "Building Core Backend"
cd /build

#workaround for jetbuild... if put in IF block it doesn't work :(
git config --global safe.directory '*'

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
