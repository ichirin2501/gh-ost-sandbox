.PHONY: docker-run docker-run-special clean


docker-run:
	docker-compose down -v
	docker-compose up -d --force-recreate --build

docker-run-special:
	docker-compose -f docker-compose-special.yml down -v
	docker-compose -f docker-compose-special.yml up -d --force-recreate --build

clean:
	docker-compose down -v
	docker-compose -f docker-compose-special.yml down -v
