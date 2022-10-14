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
COPY ./raw/${PLATFORM_DIR}/usr/sbin/dbaas-controller /usr/sbin/dbaas-controller

# qan
COPY ./raw/${PLATFORM_DIR}/usr/sbin/percona-qan-api2 /usr/sbin/percona-qan-api2

# pmm
# -- pmm-managed
COPY ./raw/${PLATFORM_DIR}/usr/sbin/pmm-managed /usr/sbin/pmm-managed
# -- pmm-agent
COPY ./raw/${PLATFORM_DIR}/usr/sbin/pmm-agent  /usr/sbin/pmm-agent
# -- pmm-admin
COPY ./raw/${PLATFORM_DIR}/usr/sbin/pmm-admin  /usr/sbin/pmm-admin

# exporters
# -- azure_metrics_exporter -> azure_exporter
COPY ./raw/${PLATFORM_DIR}/usr/local/percona/pmm2/exporters/azure_exporter /usr/local/percona/pmm2/exporters/azure_exporter
# -- mongodb_exporter
COPY ./raw/${PLATFORM_DIR}/usr/local/percona/pmm2/exporters/ /usr/local/percona/pmm2/exporters/
# -- node_exporter
COPY ./raw/${PLATFORM_DIR}/usr/local/percona/pmm2/exporters/ /usr/local/percona/pmm2/exporters/
# -- postgres_exporter
COPY ./raw/${PLATFORM_DIR}/usr/local/percona/pmm2/exporters/ /usr/local/percona/pmm2/exporters/
# -- rds_exporter
COPY ./raw/${PLATFORM_DIR}/usr/local/percona/pmm2/exporters/ /usr/local/percona/pmm2/exporters/

EXPOSE 80

CMD ["/entrypoint.sh"]
