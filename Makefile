# Host Makefile.

include Makefile.include

ifeq ($(TAG),)
TAG := 'latest'
endif

RAW_GRAFANA_TAG=`head ./components/grafana/TAG`
RAW_CORE_TAG=`head ./components/core/TAG`
RAW_EXPORTERS_TAG=`head ./components/exporters/TAG`

publish-foundation:
	./components/foundation/pull-repositories.sh
	docker --push buildx build --platform=linux/arm64/v8,linux/amd64 --tag=ritbl/pmm-x-foundation:$(TAG) \
	-f ./components/foundation/Dockerfile .

publish-raw-grafana:
	./components/grafana/pull-repositories.sh
	docker buildx build --push --platform=linux/arm64,linux/amd64 --tag=ritbl/pmm-x-raw-grafana:$(TAG) \
	-f ./components/grafana/Dockerfile .

publish-raw-core:
	./components/core/pull-repositories.sh
	docker buildx build --push --platform=linux/arm64,linux/amd64 --tag=ritbl/pmm-x-raw-core:$(TAG) \
	-f ./components/core/Dockerfile .

publish-raw-exporters:
	./components/exporters/pull-repositories.sh
	docker buildx build --push --platform=linux/arm64,linux/amd64 --tag=ritbl/pmm-x-raw-exporters:$(TAG) \
	-f ./components/exporters/Dockerfile .

publish-with-raw:
	# AMD64
	# -- grafana
	docker pull ritbl/pmm-x-raw-grafana:$(RAW_GRAFANA_TAG) --platform linux/amd64
	-docker rm pmm-x-raw-grafana-run-amd64
	-docker run  --platform linux/amd64 --name pmm-x-raw-grafana-run-amd64 ritbl/pmm-x-raw-grafana:$(RAW_GRAFANA_TAG)
	mkdir -p ./raw/amd64/
	docker cp pmm-x-raw-grafana-run-amd64:/ ./raw/amd64/
	# -- core
	docker pull ritbl/pmm-x-raw-core:$(RAW_CORE_TAG) --platform linux/amd64
	-docker rm pmm-x-raw-core-run-amd64
	-docker run  --platform linux/amd64 --name pmm-x-raw-core-run-amd64 ritbl/pmm-x-raw-core:$(RAW_CORE_TAG)
	mkdir -p ./raw/amd64/
	docker cp pmm-x-raw-core-run-amd64:/ ./raw/amd64/
	# -- exporters
	docker pull ritbl/pmm-x-raw-exporters:$(RAW_EXPORTERS_TAG) --platform linux/amd64
	-docker rm pmm-x-raw-exporters-run-amd64
	-docker run  --platform linux/amd64 --name pmm-x-raw-exporters-run-amd64 ritbl/pmm-x-raw-exporters:$(RAW_EXPORTERS_TAG)
	mkdir -p ./raw/amd64/
	docker cp pmm-x-raw-exporters-run-amd64:/ ./raw/amd64/
	# ARM64
	# -- grafana
	docker pull ritbl/pmm-x-raw-grafana:$(RAW_GRAFANA_TAG) --platform linux/arm64
	-docker rm pmm-x-raw-grafana-run-arm64
	-docker run  --platform linux/arm64 --name pmm-x-raw-grafana-run-arm64 ritbl/pmm-x-raw-grafana:$(RAW_GRAFANA_TAG)
	mkdir -p ./raw/arm64/
	docker cp pmm-x-raw-grafana-run-arm64:/ ./raw/arm64/
	# -- core
	docker pull ritbl/pmm-x-raw-core:$(RAW_CORE_TAG) --platform linux/arm64
	-docker rm pmm-x-raw-core-run-arm64
	-docker run  --platform linux/arm64 --name pmm-x-raw-core-run-arm64 ritbl/pmm-x-raw-core:$(RAW_CORE_TAG)
	mkdir -p ./raw/arm64/
	docker cp pmm-x-raw-core-run-arm64:/ ./raw/arm64/
	# -- exporters
	docker pull ritbl/pmm-x-raw-exporters:$(RAW_EXPORTERS_TAG) --platform linux/arm64
	-docker rm pmm-x-raw-exporters-run-arm64
	-docker run  --platform linux/arm64 --name pmm-x-raw-exporters-run-arm64 ritbl/pmm-x-raw-exporters:$(RAW_EXPORTERS_TAG)
	mkdir -p ./raw/arm64/
	docker cp pmm-x-raw-exporters-run-arm64:/ ./raw/arm64/

	docker buildx build --push --platform=linux/amd64,linux/arm64 --tag=ritbl/pmm-x:$(TAG) .

trigger:
	git commit --allow-empty -m "Trigger CI"
