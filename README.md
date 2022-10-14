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

## Build Troubleshooting 

#### Mac/Win:
Check if you have enough space in docker vm:

```yaml
docker run -it --rm --privileged --pid=host justincormack/nsenter1
df -h
```
