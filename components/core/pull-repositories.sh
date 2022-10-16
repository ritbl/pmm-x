#!/bin/bash
set -o errexit
set -o xtrace

clone() {
  local target=$1
  local repo=$2
  local target_dir="./deps/$target"
  local branch=$3

  if [[ ! -d $target_dir ]];then
    # --depth=1 -- causes issues with version generation
    #  pmm-agent -v
    #     #ProjectName: pmm-agent
    #     #Version: a71ad8  <---- it will fail to connect to pmm
    #     #PMMVersion: a71ad8 <---- it will fail to connect to pmm
    git clone $repo "$target_dir" --branch $branch
  fi
}

clone "pmm" "https://github.com/percona/pmm.git" "PMM-10464_grafana-telemetry"
clone "dbaas-controller" "https://github.com/percona-platform/dbaas-controller.git" "main"
clone "qan-api2" "https://github.com/percona/qan-api2.git" "main"
