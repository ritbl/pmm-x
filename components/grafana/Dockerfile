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

FROM scratch

# grafana
COPY --from=front-builder /grafana/public /usr/share/grafana/public
COPY --from=front-builder /grafana/tools /usr/share/grafana/tools
COPY --from=back-builder /grafana/bin/*/grafana-server /usr/sbin/grafana-server
COPY ./deps/grafana/conf /usr/share/grafana/conf
COPY ./deps/grafana/scripts /usr/share/grafana/scripts

COPY  --from=front-builder /grafana-dashboards/panels /usr/share/percona-dashboards/panels/
COPY  --from=front-builder /grafana-dashboards/pmm-app/dist /usr/share/percona-dashboards/panels/pmm-app/dist

CMD [""]
