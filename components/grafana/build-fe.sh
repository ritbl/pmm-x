#!/bin/bash
set -o xtrace
set -e

echo "Building Grafana"

export NODE_OPTIONS="--max_old_space_size=8000"
npm install -g npm@latest

# Grafana
cd /build/deps/grafana
yarn install
NODE_ENV=production yarn build

# Grafana Dashboards
cd /build/deps/grafana-dashboards/pmm-app
cat package.json | sed -r 's/grafana-toolkit plugin:build"/grafana-toolkit plugin:build --skipTest --skipLint"/' \
  > package.json
npm version
npm ci
NODE_ENV=production npm run build
