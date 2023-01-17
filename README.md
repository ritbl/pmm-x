## Intro

Custom PMM build with focus on simplicity and performance.

It provides linux/ARM and linux/AMD64 container images.

## Components Included

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

## How to use it

### 1: PMM development

Update docker-compose.yml

```yaml
image: perconalab/pmm-server:dev-container
```

replace with

```yaml
image: ritbl/pmm-x:<tag>
```

where tag can be found [here](https://hub.docker.com/repository/registry-1.docker.io/ritbl/pmm-x/tags?page=1&ordering=last_updated) 

### 2: How to create a Feature Build

### branch from version build

Create a branch from a version build (e.g. `v2.31.0`). The name of the branch will become container tag `TAG`.
It is recommended to follow this naming scheme `<version-build>-<jira-id>` (e.g. `v2.31.0-PMM-10600`).

Modify TAG for changes modules, update cloned branch names ([example](https://github.com/ritbl/pmm-x/pull/34/files)).

Create PR, this will trigger incremental CI build ([example](https://github.com/ritbl/pmm-x/pull/34)).

After successful build image will be available [here](https://hub.docker.com/repository/docker/ritbl/pmm-x/tags?page=1&ordering=last_updated).


Update image in `docker-compose.yml`, for example
```yaml
  image: ritbl/pmm-x:v2.31.0-PMM-10600
```
