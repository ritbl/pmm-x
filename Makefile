# Host Makefile.

include Makefile.include

ifeq ($(TAG),)
TAG := 'latest'
endif

X_FOUNDATION_TAG=`head ./components/foundation/TAG`
X_GRAFANA_TAG=`head ./components/grafana/TAG`
X_CORE_TAG=`head ./components/core/TAG`
X_EXPORTERS_TAG=`head ./components/exporters/TAG`


build-x-grafana-fe:
	make -C components/grafana build-fe

build-x-grafana-be:
	make -C components/grafana build-be

build-x-exporters-be:
	make -C components/exporters build-be

build-x-core-be:
	make -C components/core build-be

build-x-foundation:
	make -C components/foundation build

build-pmm-x:
	BUILDX_BUILDER=buildx docker buildx build --push --platform=linux/amd64,linux/arm64 --tag=ritbl/pmm-x:$(TAG) \
		--build-arg X_FOUNDATION_TAG=$(X_FOUNDATION_TAG) \
		--build-arg X_GRAFANA_TAG=$(X_GRAFANA_TAG) \
		--build-arg X_CORE_TAG=$(X_CORE_TAG) \
		--build-arg X_EXPORTERS_TAG=$(X_EXPORTERS_TAG) \
		.
