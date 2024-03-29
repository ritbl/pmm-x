#!/bin/bash
set -o errexit
set -o xtrace

clone() {
  local target=$1
  local repo=$2
  local target_dir="./deps/$target"
  local branch=$3

  if [[ ! -d $target_dir ]];then
    git clone --depth=1 $repo "$target_dir" --branch $branch --ipv4
  fi
}

clone "postgres_exporter" "https://github.com/percona/postgres_exporter.git" "main"
clone "mongodb_exporter" "https://github.com/percona/mongodb_exporter.git" "main"
clone "node_exporter" "https://github.com/percona/node_exporter.git" "main"
clone "azure_metrics_exporter" "https://github.com/percona/azure_metrics_exporter.git" "main"
clone "rds_exporter" "https://github.com/percona/rds_exporter.git" "main"

