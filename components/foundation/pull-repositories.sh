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
