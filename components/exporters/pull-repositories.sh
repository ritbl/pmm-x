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

clone "postgres_exporter" "https://github.com/percona/postgres_exporter.git"
clone "mongodb_exporter" "https://github.com/percona/mongodb_exporter.git"
clone "node_exporter" "https://github.com/percona/node_exporter.git"
clone "azure_metrics_exporter" "https://github.com/percona/azure_metrics_exporter.git"
clone "rds_exporter" "https://github.com/percona/rds_exporter.git"

