.PHONY: docker-run docker-run-special docker-run-ultra docker-down

docker-run: docker-down
	docker-compose up -d --force-recreate --build

docker-run-special: docker-down
	docker-compose -f docker-compose-special.yml up -d --force-recreate --build

docker-run-ultra: docker-down
	docker-compose -f docker-compose-ultra.yml up -d --force-recreate --build

docker-down:
	docker-compose -f docker-compose.yml \
		-f docker-compose-special.yml \
		-f docker-compose-ultra.yml \
		down -v
