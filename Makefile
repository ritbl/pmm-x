# Host Makefile.

include Makefile.include

pull-repos: 							##
	./scripts/pull-repositories.sh

build:
	./scripts/build.sh

run-fg:
	docker-compose up --build
