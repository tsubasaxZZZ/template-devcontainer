NAME=tsubasaxzzz/devcontainer
VERSION=latest

.PHONY: build
compose-build:
	 docker-compose build
.PHONY: container-build
container-build:
	 #docker build -t $(NAME):$(VERSION)  -f .devcontainer/Dockerfile .