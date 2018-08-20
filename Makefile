docker-build:
	docker-compose build

docker-stop:
	docker-compose stop

initial-setup:
	docker-compose run api rake db:setup
	docker-compose run api rake db:migrate

update-db:
	docker-compose run api rake db:migrate

setup-local-db: destroy-local-db
	docker run  -d -v pg-data:/var/lib/postgresql/data -p 5432:5432  --name postgres  postgres:10.5
	bundle exec rake db:setup db:migrate

destroy-local-db:
	docker container stop postgres || true
	docker container rm postgres || true

start-local-server: destroy-local-db setup-local-db
	./bin/rails s


serve: docker-stop docker-build update-db
	docker-compose run --service-ports api


test: docker-stop docker-build update-db
	docker-compose run -e "RAILS_ENV=test" api rake  spec
