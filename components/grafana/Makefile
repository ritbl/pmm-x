
ifeq ($(TAG),)
TAG := 'latest'
endif

enter-pack:
	docker-compose run pack bash

# TODO: add TAG if not added
build-fe:
	./pull-repositories.sh
	echo "TAG=$(TAG)" >> .env
	docker-compose --profile fe-build up --force-recreate
	docker-compose --profile fe-pack up --force-recreate

build-be:
	./pull-repositories.sh
	echo "TAG=$(TAG)" >> .env
	docker-compose --profile be-build up --force-recreate
	docker-compose --profile be-pack up --force-recreate
