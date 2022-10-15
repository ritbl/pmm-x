#!/bin/bash
set -o xtrace
set -e

echo "Building Grafana Backend"
cd /build

cd deps/grafana
go mod verify
make build-go
