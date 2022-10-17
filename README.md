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


### 3: Known issues

### 3.1: make run-all in container fails with "nosplit stack over 792 byte limit"

On aachr64, go compilation might fail with

```
# github.com/percona/pmm/managed/cmd/pmm-managed
reflect.methodValueCall: nosplit stack over 792 byte limit
reflect.methodValueCall<0>
    grows 448 bytes, calls reflect.moveMakeFuncArgPtrs<1>
        grows 288 bytes, calls internal/abi.(*IntArgRegBitmap).Get<1>
            grows 48 bytes, calls runtime.racefuncenter<1>
                grows 0 bytes, calls racefuncenter<121>
                    grows 16 bytes, calls racecall<121>
                        grows 0 bytes, calls indirect
                            grows 0 bytes, calls runtime.morestack<0>
                            8 bytes over limit

```

To fix it update `./managed/Makefile`, in `release-dev` remove `-race` option.

So that run task will look like this:

```makefile
release-dev:
	go build -gcflags="all=-N -l" -v $(PMM_LD_FLAGS) -o $(PMM_RELEASE_PATH)/ ./cmd/...
```

### 3.2: ClickHouse on Apple Silicon
Clickhouse has limited functionality on aarch64. DBaaS will fail when it tries to connect to local (native aarch64) instance.
To Fix it you need to create AMD64 container.

In `docker-compose.yml` add service:

```yaml
  ch:
    image: clickhouse/clickhouse-server:22.6.9.11-alpine
    platform: linux/amd64
    ports:
      - "9000:9000"
```

And configure `pmm-managed` to use it:

```yaml
  pmm-managed-server:
....
    environment:
...
      - PERCONA_TEST_PMM_CLICKHOUSE_ADDR=ch:9000
      - PERCONA_TEST_PMM_CLICKHOUSE_DATABASE=pmm
      - PERCONA_TEST_PMM_CLICKHOUSE_BLOCK_SIZE=10000
      - PERCONA_TEST_PMM_CLICKHOUSE_POOL_SIZE=2
...
```

Note: host in connection string `ch:9000` is name of the service you added on previous step.

