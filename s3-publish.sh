#!/bin/bash
set -o xtrace

find ./components/grafana -maxdepth 1 -name "*.yml" -exec aws s3 cp "{}" s3://pmm-x/ \;