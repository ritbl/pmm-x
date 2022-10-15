
ifeq ($(TAG),)
TAG := 'latest'
endif

enter-pack:
	docker-compose run pack bash

# TODO: add TAG if not added
build-fe:
	./pull-repositories.sh
	echo "TAG=$(TAG)" >> .env
	sed -i '' -e 's/grafana-toolkit plugin:build"/grafana-toolkit plugin:build --skipTest --skipLint"/' ./deps/grafana-dashboards/pmm-app/package.json
	docker-compose --profile build-fe up
	docker-compose --profile pack-fe up
