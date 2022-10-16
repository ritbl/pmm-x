
ifeq ($(TAG),)
TAG := 'latest'
endif

build:
	./components/foundation/pull-repositories.sh
	docker buildx build --platform=linux/arm64,linux/amd64 --tag=ritbl/pmm-x-foundation:$(TAG) \
		-f ./components/foundation/Dockerfile .
#