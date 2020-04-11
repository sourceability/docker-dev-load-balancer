.DEFAULT_GOAL := all

ifeq (, $(shell which mkcert))
    $(error "No mkcert in $(PATH). Please install mkcert, see https://github.com/FiloSottile/mkcert#installation")
endif

ssl/test.key:
	mkdir -p ./ssl
	mkcert --key-file ./ssl/test.key --cert-file ./ssl/test.crt "*.docker.test" 127.0.0.1 ::1

all: ssl/test.key
	docker network inspect traefik-docker > /dev/null 2>&1 || docker network create traefik-docker
	docker-compose up -d --remove-orphans
