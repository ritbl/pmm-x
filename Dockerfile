FROM golang:1.19.2-bullseye as back-builder

RUN apt install -y gcc g++ make

# Grafana
WORKDIR /grafana

COPY ./submodules/grafana/go.mod ./submodules/grafana/go.sum ./submodules/grafana/embed.go ./submodules/grafana/Makefile ./submodules/grafana/build.go ./submodules/grafana/package.json ./
COPY ./submodules/grafana/packages/grafana-schema packages/grafana-schema
COPY ./submodules/grafana/public/app/plugins public/app/plugins
COPY ./submodules/grafana/public/api-spec.json public/api-spec.json
COPY ./submodules/grafana/pkg pkg
COPY ./submodules/grafana/scripts scripts
COPY ./submodules/grafana/cue.mod cue.mod
COPY ./submodules/grafana/.bingo .bingo

RUN go mod verify
RUN make build-go

# PMM
WORKDIR /pmm
COPY ./submodules/pmm ./
RUN make init release

# Victoria
COPY ./submodules/VictoriaMetrics/ /VictoriaMetrics
RUN cd /VictoriaMetrics/app/victoria-metrics && \
    go build  -o victoria-metrics
RUN cd /VictoriaMetrics/app/vmalert && \
    go build  -o vmalert
RUN cd /VictoriaMetrics/app/vmagent && \
    go build  -o vmagent

# AlertManager
COPY ./submodules/alertmanager /alertmanager
RUN cd /alertmanager/cmd/alertmanager && \
    go build  -o alertmanager

# dbaas-controller
COPY ./submodules/dbaas-controller /dbaas-controller
RUN cd /dbaas-controller && \
    make release

# qan-api2
COPY ./submodules/qan-api2 /qan-api2
RUN cd /qan-api2 && \
    make release

# exporters
# -- azure_exporter
COPY ./submodules/azure_metrics_exporter /azure_metrics_exporter
RUN cd /azure_metrics_exporter && \
    go build

# -- mongodb_exporter
COPY ./submodules/mongodb_exporter /mongodb_exporter
RUN cd /mongodb_exporter && \
    go build

# -- node_exporter
COPY ./submodules/node_exporter /node_exporter
RUN cd /node_exporter && \
    go build

# -- postgres_exporter
COPY ./submodules/postgres_exporter /postgres_exporter
RUN cd /postgres_exporter/cmd/postgres_exporter && \
    go build

# -- rds_exporter
COPY ./submodules/rds_exporter /rds_exporter
RUN cd /rds_exporter && \
    go build

FROM node:16.17-bullseye as front-builder

ENV NODE_OPTIONS="--max_old_space_size=8000"
RUN npm install -g npm@latest

# Grafana Dashboards
WORKDIR /grafana

COPY submodules/grafana/package.json submodules/grafana/yarn.lock submodules/grafana/.yarnrc.yml ./
COPY submodules/grafana/.yarn ./.yarn
COPY submodules/grafana/packages ./packages
COPY submodules/grafana/plugins-bundled ./plugins-bundled

RUN yarn install

COPY submodules/grafana/tsconfig.json submodules/grafana/.eslintrc submodules/grafana/.editorconfig submodules/grafana/.browserslistrc submodules/grafana/.prettierrc.js submodules/grafana/babel.config.json submodules/grafana/.linguirc ./
COPY submodules/grafana/public public
COPY submodules/grafana/tools tools
COPY submodules/grafana/scripts scripts
COPY submodules/grafana/emails emails

RUN NODE_ENV=production yarn build

# Grafana Dashboards
WORKDIR /grafana-dashboards

COPY ./submodules/grafana-dashboards ./
WORKDIR /grafana-dashboards/pmm-app
RUN npm version && \
    npm ci
RUN NODE_ENV=production npm run build

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
COPY ./submodules/grafana/conf /usr/share/grafana/conf
COPY ./submodules/grafana/scripts /usr/share/grafana/scripts

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
COPY --from=back-builder /VictoriaMetrics/app/victoria-metrics/victoria-metrics /usr/sbin/victoriametrics

# vmalert
COPY --from=back-builder /VictoriaMetrics/app/vmalert/vmalert /usr/sbin/vmalert

# alertmanager
COPY --from=back-builder /alertmanager/cmd/alertmanager/alertmanager /usr/sbin/alertmanager

# dbaas-controller
COPY --from=back-builder /dbaas-controller/bin/dbaas-controller /usr/sbin/dbaas-controller

# qan
COPY --from=back-builder /qan-api2/bin/qan-api2 /usr/sbin/percona-qan-api2

# pmm
# -- pmm-managed
COPY --from=back-builder /pmm/bin/pmm-managed /usr/sbin/pmm-managed
# -- pmm-agent
COPY --from=back-builder /pmm/bin/pmm-agent  /usr/sbin/pmm-agent
COPY --from=back-builder /VictoriaMetrics/app/vmagent/vmagent  /usr/local/percona/pmm2/exporters/vmagent
# -- pmm-admin
COPY --from=back-builder /pmm/bin/pmm-admin  /usr/sbin/pmm-admin

# exporters
# -- azure_metrics_exporter -> azure_exporter
COPY --from=back-builder /azure_metrics_exporter/azure_metrics_exporter /usr/local/percona/pmm2/exporters/azure_exporter
# -- mongodb_exporter
COPY --from=back-builder /mongodb_exporter/mongodb_exporter /usr/local/percona/pmm2/exporters/
# -- node_exporter
COPY --from=back-builder /node_exporter/node_exporter /usr/local/percona/pmm2/exporters/
# -- postgres_exporter
COPY --from=back-builder /postgres_exporter/cmd/postgres_exporter/postgres_exporter /usr/local/percona/pmm2/exporters/
# -- rds_exporter
COPY --from=back-builder /rds_exporter/rds_exporter /usr/local/percona/pmm2/exporters/

EXPOSE 80

CMD ["/entrypoint.sh"]
