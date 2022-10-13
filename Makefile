# Host Makefile.

include Makefile.include

pull-repos: 							##
	./scripts/pull-repositories.sh

run-fg: pull-repos
	DOCKER_BUILDKIT=1 docker-compose up --build

build:
	docker run -it --rm --privileged tonistiigi/binfmt --install all # installs qemu emulators
	docker buildx create --use
	./scripts/pull-repositories.sh
	docker buildx build --platform=linux/arm64,linux/amd64 --tag=ritbl/pmm-x:0.0.1 .
	#docker buildx build --push --platform=linux/amd64,linux/arm64 --tag=ritbl/pmm-x:0.0.1 .

reset:
	git submodule foreach git reset --hard
