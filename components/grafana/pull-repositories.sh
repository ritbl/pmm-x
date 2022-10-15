#!/bin/bash
set -o errexit
set -o xtrace

clone() {
  local target=$1
  local repo=$2
  local target_dir="./deps/$target"
  local branch=$3

  if [[ ! -d $target_dir ]];then
    git clone --depth=1 $repo "$target_dir" --branch $branch
  fi
}

clone "grafana" "https://github.com/percona-platform/grafana.git" "main"
clone "grafana-dashboards" "https://github.com/percona/grafana-dashboards.git" "main"
