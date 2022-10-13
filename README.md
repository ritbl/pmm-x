## Intro

Custom PMM build with focus on simplicity and performance.

It provides native aarch64 and AMD64 (coming soon) container images, so that you can run them with full speed on M1/M2 or linux machine! 

## Components Included

Container contains:
 - SupervisorD
 - PostgreSQL
 - Clickhouse
 - VictoriaMetrics
 - Nginx
 - Grafana (Percona)
 - vmalert
 - alertmanager
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
docker buildx create --use
docker login
docker buildx build --push --platform=linux/amd64,linux/arm64 --tag=ritbl/pmm-x:0.0.1 .
```
