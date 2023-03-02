#!/bin/bash
set -o xtrace
set -e

echo "Building Grafana Backend"
cd /build

# fixes build issue on jetbuild
go env -w GOFLAGS="-buildvcs=false"

cd deps/grafana
go mod verify
make build-go
