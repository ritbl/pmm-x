FROM golang:1.19.2-buster as back-builder

RUN apt install -y gcc g++ make

# Grafana
WORKDIR /grafana

COPY ./deps/grafana/go.mod ./deps/grafana/go.sum ./deps/grafana/embed.go ./deps/grafana/Makefile ./deps/grafana/build.go ./deps/grafana/package.json ./
COPY ./deps/grafana/packages/grafana-schema packages/grafana-schema
COPY ./deps/grafana/public/app/plugins public/app/plugins
COPY ./deps/grafana/public/api-spec.json public/api-spec.json
COPY ./deps/grafana/pkg pkg
COPY ./deps/grafana/scripts scripts
COPY ./deps/grafana/cue.mod cue.mod
COPY ./deps/grafana/.bingo .bingo

RUN --mount=type=cache,target=/root/go/pkg/mod \
    go mod verify
RUN --mount=type=cache,target=/root/go/pkg/mod \
    make build-go

# PMM
WORKDIR /pmm
COPY ./deps/pmm ./
RUN --mount=type=cache,target=/root/go/pkg/mod \
    make init release

# dbaas-controller
COPY ./deps/dbaas-controller /dbaas-controller
RUN --mount=type=cache,target=/root/go/pkg/mod \
    cd /dbaas-controller && \
    make release

# qan-api2
COPY ./deps/qan-api2 /qan-api2
RUN --mount=type=cache,target=/root/go/pkg/mod \
    cd /qan-api2 && \
    make release

# exporters
# -- azure_exporter
COPY ./deps/azure_metrics_exporter /azure_metrics_exporter
RUN --mount=type=cache,target=/root/go/pkg/mod \
    cd /azure_metrics_exporter && \
    go build

# -- mongodb_exporter
COPY ./deps/mongodb_exporter /mongodb_exporter
RUN --mount=type=cache,target=/root/go/pkg/mod \
    cd /mongodb_exporter && \
    go build

# -- node_exporter
COPY ./deps/node_exporter /node_exporter
RUN --mount=type=cache,target=/root/go/pkg/mod \
    cd /node_exporter && \
    go build

# -- postgres_exporter
COPY ./deps/postgres_exporter /postgres_exporter
RUN --mount=type=cache,target=/root/go/pkg/mod \
    cd /postgres_exporter/cmd/postgres_exporter && \
    go build

# -- rds_exporter
COPY ./deps/rds_exporter /rds_exporter
RUN --mount=type=cache,target=/root/go/pkg/mod \
    cd /rds_exporter && \
    go build

FROM node:16.17-buster as front-builder

ENV NODE_OPTIONS="--max_old_space_size=8000"
RUN npm install -g npm@latest

# Grafana Dashboards
WORKDIR /grafana

COPY deps/grafana/package.json deps/grafana/yarn.lock deps/grafana/.yarnrc.yml ./
COPY deps/grafana/.yarn ./.yarn
COPY deps/grafana/packages ./packages
COPY deps/grafana/plugins-bundled ./plugins-bundled

RUN --mount=type=cache,target=/grafana/.yarn/cache \
    yarn install

COPY deps/grafana/tsconfig.json deps/grafana/.eslintrc deps/grafana/.editorconfig deps/grafana/.browserslistrc deps/grafana/.prettierrc.js deps/grafana/babel.config.json deps/grafana/.linguirc ./
COPY deps/grafana/public public
COPY deps/grafana/tools tools
COPY deps/grafana/scripts scripts
COPY deps/grafana/emails emails

RUN --mount=type=cache,target=/grafana/.yarn/cache \
    NODE_ENV=production yarn build

# Grafana Dashboards
WORKDIR /grafana-dashboards

COPY ./deps/grafana-dashboards ./
WORKDIR /grafana-dashboards/pmm-app
RUN --mount=type=cache,target=/grafana-dashboards/pmm-app/node_modules \
    npm version && \
    npm ci
RUN --mount=type=cache,target=/grafana-dashboards/pmm-app/node_modules \
    NODE_ENV=production npm run build

FROM ritbl/pmm-x-foundation:0.0.1

ARG DEBIAN_FRONTEND=noninteractive

# common
RUN adduser pmm
RUN mkdir -p \
    /srv/logs/

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

# dbaas-controller
COPY --from=back-builder /dbaas-controller/bin/dbaas-controller /usr/sbin/dbaas-controller

# qan
COPY --from=back-builder /qan-api2/bin/qan-api2 /usr/sbin/percona-qan-api2

# pmm
# -- pmm-managed
COPY --from=back-builder /pmm/bin/pmm-managed /usr/sbin/pmm-managed
# -- pmm-agent
COPY --from=back-builder /pmm/bin/pmm-agent  /usr/sbin/pmm-agent
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
