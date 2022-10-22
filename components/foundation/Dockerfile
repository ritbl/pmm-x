FROM golang:1.19.2-buster as back-builder

RUN apt install -y gcc g++ make

# Victoria
COPY ./deps/VictoriaMetrics/ /VictoriaMetrics
RUN cd /VictoriaMetrics/app/victoria-metrics && \
    go build -o victoria-metrics
RUN cd /VictoriaMetrics/app/vmalert && \
    go build -o vmalert
RUN cd /VictoriaMetrics/app/vmagent && \
    go build -o vmagent

# AlertManager
COPY ./deps/alertmanager /alertmanager
RUN cd /alertmanager/cmd/alertmanager && \
    go build -o alertmanager
RUN cd /alertmanager/cmd/amtool && \
    go build -o amtool

FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
        curl gnupg lz4 wget make vim git gcc zsh htop

RUN wget -q -O - https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh | bash \
         -s -- --unattended

RUN chsh -s /bin/zsh

# golang
# TODO: provide way to override go version
RUN wget -q -O - https://raw.githubusercontent.com/canha/golang-tools-install-script/master/goinstall.sh | bash \
         -s -- --version 1.19.2
RUN  /root/.go/bin/go install github.com/go-delve/delve/cmd/dlv@latest # TODO: .zshrc is not applied, so `go` is not available

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
COPY ./components /

# victoria
COPY --from=back-builder /VictoriaMetrics/app/victoria-metrics/victoria-metrics /usr/sbin/victoriametrics

# vmalert
COPY --from=back-builder /VictoriaMetrics/app/vmalert/vmalert /usr/sbin/vmalert

# alertmanager
COPY --from=back-builder /alertmanager/cmd/alertmanager/alertmanager /usr/sbin/alertmanager

# amtool
COPY --from=back-builder /alertmanager/cmd/amtool/amtool /usr/sbin/amtool

# vmagent
COPY --from=back-builder /VictoriaMetrics/app/vmagent/vmagent  /usr/local/percona/pmm2/exporters/vmagent

EXPOSE 80

CMD ["/entrypoint.sh"]
