## Intro

Custom PMM build with focus on simplicity and performance.

It provides native aarch64 and AMD64 (coming soon) container images, so that you can run them with full speed on M1/M2 or linux machine! 

## Components Included

Container contains:
 - SupervisorD
 - PostgreSQL
 - Clickhouse
 - VictoriaMetrics (Percona)
 - Nginx
 - Grafana (Percona)
 - vmalert
 - alertmanager
 - amtool
 - dbaas-controller
 - qan-api2
 - pmm-managed
 - pmm-agent
 - vmagent
 - pmm-admin
 - exporters
   - postgres_exporter (Percona)
   - mongodb_exporter (Percona)
   - node_exporter (Percona)
   - azure_metrics_exporter (Percona)
   - rds_exporter (Percona)

## Docker 

Configure docker to use buildx, build and push image.

```bash
# setup (once)
#docker run -it --rm --privileged tonistiigi/binfmt --install all # installs qemu emulators
docker run -it --rm --privileged tonistiigi/binfmt --install x86_64
docker run -it --rm --privileged tonistiigi/binfmt --install arm
docker buildx create --use

# login and push
docker login
docker buildx build --push --platform=linux/amd64,linux/arm64 --tag=ritbl/pmm-x:0.0.1 .
```

## How to use it

### 1: PMM development:

Update docker-compose.yml

```yaml
image: perconalab/pmm-server:dev-container
```

replace with

```yaml
image: ritbl/pmm-x:<tag>
```

where tag can be found [here](https://hub.docker.com/repository/registry-1.docker.io/ritbl/pmm-x/tags?page=1&ordering=last_updated) 

### 2: Feature Build

### 2.1: Feature Build From PMM (core)

#### a: creating custom pmm-core build:

Modify `/components/core/pull-repositories.sh`, set branch name where needed.
```
clone "pmm" "https://github.com/percona/pmm.git" <branch> # provide if needed
clone "dbaas-controller" "https://github.com/percona-platform/dbaas-controller.git" <branch> # provide if needed
clone "qan-api2" "https://github.com/percona/qan-api2.git" <branch> # provide if needed
```

Push to branch with following format `RAW/<tag>`, for example `RAW/PMM-10600-add-mongodb-edition-datapoint`.

Create draft PR with title: `core: <tag>`, for example `core: PMM-10600-add-mongodb-edition-datapoint` ([link](https://github.com/ritbl/pmm-x/pull/14)).

This will trigger CI build, eventually pmm-core component will be published to dockerhub container repository.

#### b: creating custom pmm-x build:

Checkout `main` branch.

Modify `./components/core/TAG`, use tag from step `2.1a`.

Make sure that dependent component is published (from step 2.1a).
Push to branch with following format `FB/<tag>`, for example `FB/PMM-10600-add-mongodb-edition-datapoint`.

Create draft PR with title: `FB: <tag>`, for example `FB: PMM-10600-add-mongodb-edition-datapoint` ([link](https://github.com/ritbl/pmm-x/pull/14)).

This will trigger CI build, eventually pmm-core component will be published to dockerhub container repository.
