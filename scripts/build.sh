#!/bin/bash
set -o errexit
set -o xtrace

export GOARCH=arm64
export GOOS=linux

cd ./deps/VictoriaMetrics/app/victoria-metrics
go build  -o victoria-metrics.linux.arm64
cd -

cd ./deps/VictoriaMetrics/app/vmalert
go build  -o vmalert.linux.arm64
cd -

cd ./deps/VictoriaMetrics/app/vmagent
go build  -o vmagent.linux.arm64
cd -

cd ./deps/alertmanager/cmd/alertmanager
go build  -o alertmanager.linux.arm64
cd -

cd ./deps/dbaas-controller
make release
cd -

cd ./deps/qan-api2
make release
cd -

cd ./deps/grafana-dashboards
make release
cd -

# exporters
# -- azure_exporter
cd ./deps/azure_metrics_exporter
go build
cd -
# -- mongodb_exporter
cd ./deps/mongodb_exporter
go build
cd -
# node_exporter
cd ./deps/node_exporter
go build
cd -
# postgres_exporter
cd ./deps/postgres_exporter/cmd/postgres_exporter
go build
cd -

# postgres_exporter
cd ./deps/rds_exporter
go build
cd -
