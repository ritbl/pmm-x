ARG X_FOUNDATION_TAG
FROM ritbl/pmm-x-foundation:$X_FOUNDATION_TAG

ARG TARGETARCH
ARG DEBIAN_FRONTEND=noninteractive

# common
RUN adduser pmm
RUN mkdir -p \
    /srv/logs/

# grafana
RUN adduser grafana
RUN mkdir -p /usr/share/grafana/data
COPY ./deps/${TARGETARCH}/usr/share/grafana/public /usr/share/grafana/public
COPY ./deps/${TARGETARCH}/usr/share/grafana/tools /usr/share/grafana/tools
COPY ./deps/${TARGETARCH}/usr/sbin/grafana-server /usr/sbin/grafana-server
COPY ./deps/${TARGETARCH}/usr/share/grafana/conf /usr/share/grafana/conf
COPY ./deps/${TARGETARCH}/usr/share/grafana/conf /usr/share/grafana/scripts

COPY  ./deps/${TARGETARCH}/usr/share/percona-dashboards/panels/ /usr/share/percona-dashboards/panels/
COPY  ./deps/${TARGETARCH}/usr/share/percona-dashboards/panels/pmm-app/dist /usr/share/percona-dashboards/panels/pmm-app/dist

# dbaas-controller
COPY ./deps/${TARGETARCH}/usr/sbin/dbaas-controller /usr/sbin/dbaas-controller

# qan
COPY ./deps/${TARGETARCH}/usr/sbin/percona-qan-api2 /usr/sbin/percona-qan-api2

# pmm
# -- pmm-managed
COPY ./deps/${TARGETARCH}/usr/sbin/pmm-managed /usr/sbin/pmm-managed
# -- pmm-agent
COPY ./deps/${TARGETARCH}/usr/sbin/pmm-agent  /usr/sbin/pmm-agent
# -- pmm-admin
COPY ./deps/${TARGETARCH}/usr/sbin/pmm-admin  /usr/sbin/pmm-admin

# exporters
# -- azure_metrics_exporter -> azure_exporter
COPY ./deps/${TARGETARCH}/usr/local/percona/pmm2/exporters/azure_exporter /usr/local/percona/pmm2/exporters/azure_exporter
# -- mongodb_exporter
COPY ./deps/${TARGETARCH}/usr/local/percona/pmm2/exporters/ /usr/local/percona/pmm2/exporters/
# -- node_exporter
COPY ./deps/${TARGETARCH}/usr/local/percona/pmm2/exporters/ /usr/local/percona/pmm2/exporters/
# -- postgres_exporter
COPY ./deps/${TARGETARCH}/usr/local/percona/pmm2/exporters/ /usr/local/percona/pmm2/exporters/
# -- rds_exporter
COPY ./deps/${TARGETARCH}/usr/local/percona/pmm2/exporters/ /usr/local/percona/pmm2/exporters/

EXPOSE 80

CMD ["/entrypoint.sh"]
