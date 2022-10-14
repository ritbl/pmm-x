FROM golang:1.19.2-buster as back-builder

RUN apt install -y gcc g++ make

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

FROM scratch

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

CMD [""]
