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

clone "grafana" "https://github.com/percona-platform/grafana.git"
clone "grafana-dashboards" "https://github.com/percona/grafana-dashboards.git"
