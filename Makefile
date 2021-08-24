.PHONY: docker-run docker-run-special docker-run-ultra


docker-run:
	docker-compose down -v
	docker-compose up -d --force-recreate --build

docker-run-special:
	docker-compose -f docker-compose-special.yml down -v
	docker-compose -f docker-compose-special.yml up -d --force-recreate --build

docker-run-ultra:
	docker-compose -f docker-compose-ultra.yml down -v
	docker-compose -f docker-compose-ultra.yml up -d --force-recreate --build

