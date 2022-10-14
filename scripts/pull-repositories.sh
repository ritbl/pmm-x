#!/bin/bash
set -o errexit
set -o xtrace

clone() {
  local target=$1
  local repo=$2
  local target_dir="./deps/$target"
  local tag=$3

  if [[ ! -d $target_dir ]];then
    git clone $repo "$target_dir"
  fi

  if [[ ! -z $tag ]];then
      cd "$target_dir"
      git checkout $tag
      cd -
  fi
}

clone "VictoriaMetrics" "https://github.com/VictoriaMetrics/VictoriaMetrics.git" "pmm-6401-v1.77.1"
clone "alertmanager" "https://github.com/prometheus/alertmanager.git"
clone "grafana" "https://github.com/percona-platform/grafana.git"
clone "grafana-dashboards" "https://github.com/percona/grafana-dashboards.git"
clone "pmm" "https://github.com/percona/pmm.git"
clone "dbaas-controller" "https://github.com/percona-platform/dbaas-controller.git"
clone "qan-api2" "https://github.com/percona/qan-api2.git"

## exporters
clone "postgres_exporter" "https://github.com/percona/postgres_exporter.git"
clone "mongodb_exporter" "https://github.com/percona/mongodb_exporter.git"
clone "node_exporter" "https://github.com/percona/node_exporter.git"
clone "azure_metrics_exporter" "https://github.com/percona/azure_metrics_exporter.git"
clone "rds_exporter" "https://github.com/percona/rds_exporter.git"
