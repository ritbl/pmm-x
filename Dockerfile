ARG X_FOUNDATION_TAG
FROM ritbl/pmm-x-foundation:$X_FOUNDATION_TAG

ARG TARGETARCH
ARG X_EXPORTERS_TAG
ARG X_GRAFANA_TAG
ARG X_CORE_TAG
ARG DEBIAN_FRONTEND=noninteractive

# common
RUN adduser pmm
RUN mkdir -p \
    /srv/logs/

# grafana
RUN adduser grafana
RUN mkdir -p /usr/share/grafana/data

COPY build-pmm-x.sh /
RUN /build-pmm-x.sh && rm /build-pmm-x.sh

EXPOSE 80

CMD ["/entrypoint.sh"]
