
ifeq ($(TAG),)
TAG := 'latest'
endif

build:
	rm -rf ./deps
	rm -rf ./pack
	rm *.tar.lz4
	./pull-repositories.sh
	docker buildx build --push --platform=linux/arm64,linux/amd64 --tag=ritbl/pmm-x-foundation:$(TAG) \
		-f ./Dockerfile .
