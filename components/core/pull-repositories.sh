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

clone "pmm" "https://github.com/percona/pmm.git"
clone "dbaas-controller" "https://github.com/percona-platform/dbaas-controller.git"
clone "qan-api2" "https://github.com/percona/qan-api2.git"
