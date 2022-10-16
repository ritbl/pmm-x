#!/bin/bash
set -o xtrace

find ./components/grafana -maxdepth 1 -name "*.tar.lz4" -exec aws s3 cp "{}" s3://pmm-x/ \;
find ./components/exporters -maxdepth 1 -name "*.tar.lz4" -exec aws s3 cp "{}" s3://pmm-x/ \;
find ./components/core -maxdepth 1 -name "*.tar.lz4" -exec aws s3 cp "{}" s3://pmm-x/ \;