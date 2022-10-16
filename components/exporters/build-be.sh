#!/bin/bash
set -o xtrace
set -e

echo "Building Exporters Backend"
cd /build

## -- azure_exporter
cd ./deps/azure_metrics_exporter
go build
cd -

## -- mongodb_exporter
cd ./deps/mongodb_exporter
go build
cd -

## -- node_exporter
cd ./deps/node_exporter
go build
cd -

## -- postgres_exporter
cd ./deps/postgres_exporter/cmd/postgres_exporter
go build
cd -

## -- rds_exporter
cd ./deps/rds_exporter
go build
cd -
