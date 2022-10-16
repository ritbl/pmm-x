#!/bin/bash
set -o xtrace
set -e

echo "Packing Grafana FE"
cd /build

if ! command -v lz4 &> /dev/null
then
  apt update
  apt install lz4
fi

rm -rf pack
mkdir pack
cd pack

# -- grafana
mkdir -p ./usr/share/grafana/public
cp -r ../deps/grafana/public ./usr/share/grafana/public
cp -r ../deps/grafana/tools ./usr/share/grafana/tools
cp -r ../deps/grafana/conf ./usr/share/grafana/conf
cp -r ../deps/grafana/scripts ./usr/share/grafana/scripts
# -- percona-dashboards
mkdir -p ./usr/share/percona-dashboards/panels/
cp -r ../deps/grafana-dashboards/panels ./usr/share/percona-dashboards/panels/
mkdir -p ./usr/share/percona-dashboards/panels/pmm-app/dist
cp -r ../deps/grafana-dashboards/pmm-app/dist ./usr/share/percona-dashboards/panels/pmm-app/dist
cd ..

# compress
tar -I 'lz4 --fast' -cf ../x-grafana-fe-$TAG.tar.lz4 ./
