# Host Makefile.

include Makefile.include

ifeq ($(TAG),)
TAG := 'latest'
endif

ifeq ($(RAW_TAG),)
RAW_TAG := '0.0.1'
endif

publish-foundation:
	docker buildx build --push --platform=linux/arm64,linux/amd64 --tag=ritbl/pmm-x-foundation:$(TAG) \
	-f ./components/foundation/Dockerfile .

publish-raw-grafana:
	./components/grafana/pull-repositories.sh
	docker buildx build --push --platform=linux/arm64,linux/amd64 --tag=ritbl/pmm-x-raw-grafana:$(TAG) \
	-f ./components/grafana/Dockerfile .

publish-raw-core:
	./components/core/pull-repositories.sh
	docker buildx build --push --platform=linux/arm64,linux/amd64 --tag=ritbl/pmm-x-core-grafana:$(TAG) \
	-f ./components/core/Dockerfile .

trigger:
	git commit --allow-empty -m "Trigger CI"

# ready ^^

# WIP ^^

publish-with-raw:
	# AMD64
	docker pull ritbl/pmm-x-raw-grafana:$(RAW_TAG) --platform linux/amd64
	-docker rm pmm-x-raw-grafana-run-amd64
	-docker run  --platform linux/amd64 --name pmm-x-raw-grafana-run-amd64 ritbl/pmm-x-raw-grafana:$(RAW_TAG)
	mkdir -p ./raw/amd64/
	docker cp pmm-x-raw-grafana-run-amd64:/ ./raw/amd64/
	# ARM64
	docker pull ritbl/pmm-x-raw-grafana:$(RAW_TAG) --platform linux/arm64
	-docker rm pmm-x-raw-grafana-run-arm64
	-docker run  --platform linux/arm64 --name pmm-x-raw-grafana-run-arm64 ritbl/pmm-x-raw-grafana:$(RAW_TAG)
	mkdir -p ./raw/arm64/
	docker cp pmm-x-raw-grafana-run-arm64:/ ./raw/arm64/

	docker build -t ritbl/pmm-x:$(TAG)-amd64 --build-arg PLATFORM=amd64 --build-arg PLATFORM_DIR=amd64 -f ./multi.Dockerfile .
	docker push ritbl/pmm-x:$(TAG)-amd64
	docker build -t ritbl/pmm-x:$(TAG)-arm64 --build-arg PLATFORM=arm64 --build-arg PLATFORM_DIR=arm64 -f ./multi.Dockerfile .
	docker push ritbl/pmm-x:$(TAG)-arm64
	docker manifest create \
	    ritbl/pmm-x:$(TAG) \
		--amend ritbl/pmm-x:$(TAG)-arm64 \
		--amend ritbl/pmm-x:$(TAG)-amd64
	docker manifest push \
	    ritbl/pmm-x:$(TAG)

# TODO VV

pull-repos: 							##
	./scripts/pull-repositories.sh

run-fg: pull-repos
	DOCKER_BUILDKIT=1 docker-compose up --build

prepare:
	#docker run -it --rm --privileged tonistiigi/binfmt --install all # installs qemu emulators
	docker buildx create --use
	./scripts/pull-repositories.sh

build-amd64:
	docker buildx build --platform=linux/amd64 --tag=ritbl/pmm-x:$(TAG) .

publish-amd64:
	docker buildx build --push --platform=linux/amd64 --tag=ritbl/pmm-x:$(TAG) .

build-arm64:
	docker buildx build --platform=linux/arm64 --tag=ritbl/pmm-x:$(TAG) .

publish-arm64:
	docker buildx build --push --platform=linux/arm64 --tag=ritbl/pmm-x:$(TAG) .

publish:
	docker buildx build --push --platform=linux/arm64,linux/amd64 --tag=ritbl/pmm-x:$(TAG) .
