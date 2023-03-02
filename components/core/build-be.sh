#!/bin/bash
set -o xtrace
set -e

echo "Building Core Backend"
cd /build

#if [ x"${X_FIX_GIT_ACCESS}" == "1" ]; then
#  echo "Fixing git access"
git config --global safe.directory '*'
#else
#  echo "Skipping fixing git access"
#fi

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
