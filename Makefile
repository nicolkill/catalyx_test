IMAGE_TAG := nicolkill/catalyx_test
REVISION := $(shell git rev-parse --short HEAD)
RUN_STANDARD := docker run --rm -v `pwd`:/app -w /app hexpm/elixir:1.15.4-erlang-26.0.2-alpine-3.18.2

all: build image

up:
	docker compose up

build:
	$(RUN_STANDARD) sh -c 'apk update && mix do local.rebar --force, local.hex --force, \
                           		deps.get, \
                           		deps.compile --force, \
                           		compile --plt'

image:
	docker build -t ${IMAGE_TAG}:${REVISION} .
	docker tag ${IMAGE_TAG}:${REVISION} ${IMAGE_TAG}:latest

testing:
	docker compose exec app mix test

iex:
	docker compose exec app iex -S mix

bash:
	docker compose run --rm app sh

routes:
	docker compose exec app mix phx.routes

rollback:
	docker compose exec app mix ecto.rollback

migrate:
	docker compose exec app mix ecto.migrate

format:
	docker compose exec app mix format
