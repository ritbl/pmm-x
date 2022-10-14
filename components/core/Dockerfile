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

FROM scratch

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

CMD [""]
