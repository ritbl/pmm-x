
ifeq ($(TAG),)
TAG := 'latest'
endif

enter-pack:
	docker-compose run pack bash

# TODO: add TAG if not added
build-fe:
	rm -rf ./deps
	rm -rf ./pack
	rm *.tar.lz4
	./pull-repositories.sh
	echo "TAG=$(TAG)" >> .env
	docker-compose --profile fe-build up --force-recreate
	docker-compose --profile fe-pack up --force-recreate

build-be:
	rm -rf ./deps
	rm -rf ./pack
	rm *.tar.lz4
	./pull-repositories.sh
	echo "TAG=$(TAG)" >> .env
	docker-compose --profile be-build up --force-recreate
	docker-compose --profile be-pack up --force-recreate
