
ifeq ($(TAG),)
TAG := 'latest'
endif

enter-pack:
	docker-compose run pack bash

unpack:
	mkdir unpack
	tar --lz4 -xvf x-exporters-be-arm64-latest.tar.lz4 -C ./unpack

# TODO: add TAG if not added
build-be:
	./pull-repositories.sh
	echo "TAG=$(TAG)" >> .env
	docker-compose --profile be-build up --force-recreate
	docker-compose --profile be-pack up --force-recreate
