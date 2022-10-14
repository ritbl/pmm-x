FROM golang:1.19.2-buster as back-builder

RUN apt install -y gcc g++ make

# PMM
WORKDIR /pmm
COPY ./deps/pmm ./
RUN make init release

# dbaas-controller
COPY ./deps/dbaas-controller /dbaas-controller
RUN cd /dbaas-controller && \
    make release

# qan-api2
COPY ./deps/qan-api2 /qan-api2
RUN cd /qan-api2 && \
    make release

# exporters
# -- azure_exporter
COPY ./deps/azure_metrics_exporter /azure_metrics_exporter
RUN cd /azure_metrics_exporter && \
    go build

# -- mongodb_exporter
COPY ./deps/mongodb_exporter /mongodb_exporter
RUN cd /mongodb_exporter && \
    go build

# -- node_exporter
COPY ./deps/node_exporter /node_exporter
RUN cd /node_exporter && \
    go build

# -- postgres_exporter
COPY ./deps/postgres_exporter /postgres_exporter
RUN cd /postgres_exporter/cmd/postgres_exporter && \
    go build

# -- rds_exporter
COPY ./deps/rds_exporter /rds_exporter
RUN cd /rds_exporter && \
    go build

ARG PLATFORM
FROM --platform=${PLATFORM} ritbl/pmm-x-foundation:0.0.1
ARG PLATFORM_DIR

ARG DEBIAN_FRONTEND=noninteractive

# common
RUN adduser pmm
RUN mkdir -p \
    /srv/logs/

# grafana
RUN adduser grafana
RUN mkdir -p /usr/share/grafana/data
COPY ./raw/${PLATFORM_DIR}/usr/share/grafana/public /usr/share/grafana/public
COPY ./raw/${PLATFORM_DIR}/usr/share/grafana/tools /usr/share/grafana/tools
COPY ./raw/${PLATFORM_DIR}/usr/sbin/grafana-server /usr/sbin/grafana-server
COPY ./raw/${PLATFORM_DIR}/usr/share/grafana/conf /usr/share/grafana/conf
COPY ./raw/${PLATFORM_DIR}/usr/share/grafana/conf /usr/share/grafana/scripts

COPY  ./raw/${PLATFORM_DIR}/usr/share/percona-dashboards/panels/ /usr/share/percona-dashboards/panels/
COPY  ./raw/${PLATFORM_DIR}/usr/share/percona-dashboards/panels/pmm-app/dist /usr/share/percona-dashboards/panels/pmm-app/dist

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
