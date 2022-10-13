FROM golang:1.19.2-bullseye as back-builder

RUN apt install -y gcc g++ make

WORKDIR /grafana

COPY deps/grafana/go.mod deps/grafana/go.sum deps/grafana/embed.go deps/grafana/Makefile deps/grafana/build.go deps/grafana/package.json ./
COPY deps/grafana/packages/grafana-schema packages/grafana-schema
COPY deps/grafana/public/app/plugins public/app/plugins
COPY deps/grafana/public/api-spec.json public/api-spec.json
COPY deps/grafana/pkg pkg
COPY deps/grafana/scripts scripts
COPY deps/grafana/cue.mod cue.mod
COPY deps/grafana/.bingo .bingo

RUN go mod verify
RUN make build-go

FROM node:16.17-bullseye as front-builder

ENV NODE_OPTIONS="--max_old_space_size=8000"

# Grafana Dashboards
WORKDIR /grafana

COPY deps/grafana/package.json deps/grafana/yarn.lock deps/grafana/.yarnrc.yml ./
COPY deps/grafana/.yarn .yarn
COPY deps/grafana/packages packages
COPY deps/grafana/plugins-bundled plugins-bundled

RUN yarn install

COPY deps/grafana/tsconfig.json deps/grafana/.eslintrc deps/grafana/.editorconfig deps/grafana/.browserslistrc deps/grafana/.prettierrc.js deps/grafana/babel.config.json deps/grafana/.linguirc ./
COPY deps/grafana/public public
COPY deps/grafana/tools tools
COPY deps/grafana/scripts scripts
COPY deps/grafana/emails emails

ENV NODE_ENV production
RUN yarn build

# Grafana Dashboards
WORKDIR /grafana-dashboards

RUN npm install -g npm@latest

COPY ./deps/grafana-dashboards ./
WORKDIR /grafana-dashboards/pmm-app
RUN npm version
RUN	npm ci
RUN	npm i -g @grafana/toolkit
RUN npm run build

FROM golang:1.19.2-bullseye as pmm-builder

RUN apt install -y gcc g++ make

WORKDIR /pmm

COPY deps/pmm ./

RUN make init release

FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

# common
RUN adduser pmm
RUN mkdir -p \
    /srv/logs/

RUN apt-get update && apt-get install -y \
        curl gnupg

# grafana
RUN adduser grafana
RUN mkdir -p /usr/share/grafana/data
COPY --from=front-builder /grafana/public /usr/share/grafana/public
COPY --from=front-builder /grafana/tools /usr/share/grafana/tools
COPY --from=back-builder /grafana/bin/*/grafana-server /usr/sbin/grafana-server
COPY ./deps/grafana/conf /usr/share/grafana/conf
COPY ./deps/grafana/scripts /usr/share/grafana/scripts

COPY  --from=front-builder /grafana-dashboards/panels /usr/share/percona-dashboards/panels/
COPY  --from=front-builder /grafana-dashboards/pmm-app/dist /usr/share/percona-dashboards/panels/pmm-app/dist

# clickhouse
RUN apt-get install -y apt-transport-https ca-certificates dirmngr && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 8919F6BD2B48D754 && \
    echo "deb https://packages.clickhouse.com/deb stable main" | tee /etc/apt/sources.list.d/clickhouse.list && \
    apt-get update && \
    apt-get install -y clickhouse-server clickhouse-client

# supervisor, nginx, pg
RUN adduser nginx
RUN apt-get install -y \
        supervisor \
        nginx \
        postgresql postgresql-contrib

# core components
COPY components /

# victoria
COPY deps/VictoriaMetrics/app/victoria-metrics/victoria-metrics.linux.arm64 /usr/sbin/victoriametrics

# vmalert
COPY deps/VictoriaMetrics/app/vmalert/vmalert.linux.arm64 /usr/sbin/vmalert

# alertmanager
COPY ./deps/alertmanager/cmd/alertmanager/alertmanager.linux.arm64 /usr/sbin/alertmanager

# dbaas-controller
COPY ./deps/dbaas-controller/bin/dbaas-controller /usr/sbin/dbaas-controller

# qan
COPY ./deps/qan-api2/bin/qan-api2 /usr/sbin/percona-qan-api2

# pmm
# -- pmm-managed
COPY --from=pmm-builder /pmm/bin/pmm-managed /usr/sbin/pmm-managed
# -- pmm-agent
COPY --from=pmm-builder /pmm/bin/pmm-agent  /usr/sbin/pmm-agent
COPY deps/VictoriaMetrics/app/vmagent/vmagent.linux.arm64  /usr/local/percona/pmm2/exporters/vmagent
# -- pmm-admin
COPY --from=pmm-builder /pmm/bin/pmm-admin  /usr/sbin/pmm-admin

# exporters
# -- azure_metrics_exporter -> azure_exporter
COPY ./deps/azure_metrics_exporter/azure_metrics_exporter /usr/local/percona/pmm2/exporters/azure_exporter
# -- mongodb_exporter
COPY ./deps/mongodb_exporter/mongodb_exporter /usr/local/percona/pmm2/exporters/
# -- node_exporter
COPY ./deps/node_exporter/node_exporter /usr/local/percona/pmm2/exporters/
# -- postgres_exporter
COPY ./deps/postgres_exporter/cmd/postgres_exporter/postgres_exporter /usr/local/percona/pmm2/exporters/
# -- rds_exporter
COPY ./deps/rds_exporter/rds_exporter /usr/local/percona/pmm2/exporters/

EXPOSE 80

CMD ["/entrypoint.sh"]
