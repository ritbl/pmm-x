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

clone "VictoriaMetrics" "https://github.com/VictoriaMetrics/VictoriaMetrics.git" "pmm-6401-v1.77.1"
clone "alertmanager" "https://github.com/prometheus/alertmanager.git" "main"
