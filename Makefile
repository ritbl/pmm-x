# Host Makefile.

include Makefile.include

ifeq ($(TAG),)
TAG := '0.0.1'
endif

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

build-amd64:
	docker buildx build --push --platform=linux/amd64 --tag=ritbl/pmm-x:$(TAG) .

build-arm64:
	docker buildx build --platform=linux/arm64 --tag=ritbl/pmm-x:$(TAG) .

build-arm64:
	docker buildx build --push --platform=linux/arm64 --tag=ritbl/pmm-x:$(TAG) .

reset:
	git submodule foreach git reset --hard
