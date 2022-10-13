# Host Makefile.

include Makefile.include

pull-repos: 							##
	./scripts/pull-repositories.sh

run-fg: pull-repos
	DOCKER_BUILDKIT=1 docker-compose up --build
