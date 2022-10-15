# Host Makefile.

include Makefile.include

ifeq ($(TAG),)
TAG := 'latest'
endif

X_GRAFANA_TAG=`head ./components/grafana/TAG`
X_CORE_TAG=`head ./components/core/TAG`
X_EXPORTERS_TAG=`head ./components/exporters/TAG`


build-x-grafana-fe:
	make -C components/grafana build-fe

build-x-grafana-be:
	make -C components/grafana build-be


# ---- OLD
#
#publish-x-foundation-arm64:
#	./components/foundation/pull-repositories.sh
#	docker buildx build --platform=linux/arm64/v8 --tag=ritbl/pmm-x-foundation-arm64:$(TAG) \
#		-f ./components/foundation/Dockerfile .
#
#publish-x-foundation-amd64:
#	./components/foundation/pull-repositories.sh
#	docker buildx build --platform=linux/amd64 --tag=ritbl/pmm-x-foundation-amd64:$(TAG) \
#		-f ./components/foundation/Dockerfile .
#
#publish-x-grafana-arm:
##	./components/grafana/pull-repositories.sh
##	# get rig of tests (TODO: submit PR to `grafana-dashboards` that add --skipTest option)
##	cd ./deps/grafana-dashboards && \
##		sed -i '' -e 's/grafana-toolkit plugin:build"/grafana-toolkit plugin:build --skipTest --skipLint"/' ./pmm-app/package.json
#	docker buildx build --platform=linux/arm64/v8 --tag=ritbl/pmm-x-foundation-arm64:$(TAG) \
#		-f ./components/grafana/Dockerfile --no-cache -o "type=tar,dest=grafana-arm64.tar" .
#	#docker build -t=ritbl/pmm-x-grafana-arm:$(TAG) \
#	#	-f ./components/grafana/Dockerfile .
#
##publish-x-grafana:
##	./components/grafana/pull-repositories.sh
##	docker buildx build --push --platform=linux/arm64,linux/amd64 --tag=ritbl/pmm-x-grafana:$(TAG) \
##	-f ./components/grafana/Dockerfile .
#
#publish-x-grafana:
#	./components/grafana/pull-repositories.sh
#	docker buildx build --push --platform=linux/arm64,linux/amd64 --tag=ritbl/pmm-x-grafana:$(TAG) \
#	-f ./components/grafana/Dockerfile .
#
#publish-x-core:
#	./components/core/pull-repositories.sh
#	docker buildx build --push --platform=linux/arm64,linux/amd64 --tag=ritbl/pmm-x-core:$(TAG) \
#	-f ./components/core/Dockerfile .
#
#publish-x-exporters:
#	./components/exporters/pull-repositories.sh
#	docker buildx build --push --platform=linux/arm64,linux/amd64 --tag=ritbl/pmm-x-exporters:$(TAG) \
#	-f ./components/exporters/Dockerfile .
#
#publish:
#	# AMD64
#	# -- grafana
#	docker pull ritbl/pmm-x-grafana:$(RAW_GRAFANA_TAG) --platform linux/amd64
#	-docker rm pmm-x-grafana-run-amd64
#	-docker run  --platform linux/amd64 --name pmm-x-grafana-run-amd64 ritbl/pmm-x-grafana:$(RAW_GRAFANA_TAG)
#	mkdir -p ./raw/amd64/
#	docker cp pmm-x-grafana-run-amd64:/ ./raw/amd64/
#	# -- core
#	docker pull ritbl/pmm-x-core:$(RAW_CORE_TAG) --platform linux/amd64
#	-docker rm pmm-x-core-run-amd64
#	-docker run  --platform linux/amd64 --name pmm-x-core-run-amd64 ritbl/pmm-x-core:$(RAW_CORE_TAG)
#	mkdir -p ./raw/amd64/
#	docker cp pmm-x-core-run-amd64:/ ./raw/amd64/
#	# -- exporters
#	docker pull ritbl/pmm-x-exporters:$(RAW_EXPORTERS_TAG) --platform linux/amd64
#	-docker rm pmm-x-exporters-run-amd64
#	-docker run  --platform linux/amd64 --name pmm-x-exporters-run-amd64 ritbl/pmm-x-exporters:$(RAW_EXPORTERS_TAG)
#	mkdir -p ./raw/amd64/
#	docker cp pmm-x-exporters-run-amd64:/ ./raw/amd64/
#	# ARM64
#	# -- grafana
#	docker pull ritbl/pmm-x-grafana:$(RAW_GRAFANA_TAG) --platform linux/arm64
#	-docker rm pmm-x-grafana-run-arm64
#	-docker run  --platform linux/arm64 --name pmm-x-grafana-run-arm64 ritbl/pmm-x-grafana:$(RAW_GRAFANA_TAG)
#	mkdir -p ./raw/arm64/
#	docker cp pmm-x-grafana-run-arm64:/ ./raw/arm64/
#	# -- core
#	docker pull ritbl/pmm-x-core:$(RAW_CORE_TAG) --platform linux/arm64
#	-docker rm pmm-x-core-run-arm64
#	-docker run  --platform linux/arm64 --name pmm-x-core-run-arm64 ritbl/pmm-x-core:$(RAW_CORE_TAG)
#	mkdir -p ./raw/arm64/
#	docker cp pmm-x-core-run-arm64:/ ./raw/arm64/
#	# -- exporters
#	docker pull ritbl/pmm-x-exporters:$(RAW_EXPORTERS_TAG) --platform linux/arm64
#	-docker rm pmm-x-exporters-run-arm64
#	-docker run  --platform linux/arm64 --name pmm-x-exporters-run-arm64 ritbl/pmm-x-exporters:$(RAW_EXPORTERS_TAG)
#	mkdir -p ./raw/arm64/
#	docker cp pmm-x-exporters-run-arm64:/ ./raw/arm64/
#
#	docker buildx build --push --platform=linux/amd64,linux/arm64 --tag=ritbl/pmm-x:$(TAG) .
#
#trigger:
#	git commit --allow-empty -m "Trigger CI"
