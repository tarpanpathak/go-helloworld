## -----------------------------------------------------------------------------
## Make targets for building, publishing, and deploying this application.
## -----------------------------------------------------------------------------

# Dynamic variables - passed at runtime
GH_ORG?=tarpanpathak
DKR_REGISTRY?=ghcr.io
DKR_REGISTRY_TOKEN?=${GH_TOKEN}
DKR_REGISTRY_USER?=${GH_USER}
DKR_REPOSITORY?=${GH_ORG}/${APP}
DKR_IMG_SEMREL?=
DKR_IMG_TAG?=main
DKR_IMG?=${DKR_REGISTRY}/${DKR_REPOSITORY}:${DKR_IMG_TAG}

# Static variables
BRANCH=$(shell git rev-parse --abbrev-ref HEAD)
COMMIT=$(shell git rev-parse --short HEAD)
CWD=$(shell pwd)
APP=$(shell basename "${CWD}")
GO_VERSION=1.19.1

# Avoid name collisions between targets and files.
.PHONY: help build run test release-dry release \
	build-docker run-docker login-docker push-docker logout-docker images-docker debug-docker clean-docker \
	clean-release clean-all

# A target to format and present all supported targets with their descriptions.
help : Makefile
		@sed -n 's/^##//p' $<

## build 		: Compile the application.
build:
	go build -o ${APP}

## run 		: Run the application.
run:
	./${APP}

## test		: Run unit tests for the application.
test:
	go test -v -race ./...

## release-dry 	: Generate a new the version without creating a new release.
release-dry: clean-release
	semantic-release \
		--token ${DKR_REGISTRY_TOKEN} \
		--allow-no-changes --dry --no-ci \
		--provider-opt "slug=tarpanpathak/helloworld"

## release 	: Generate a new SemVer based module tag using Semantic Release.
release:
	semantic-release \
		--token ${DKR_REGISTRY_TOKEN} \
		--allow-no-changes \
		--version-file \
		--provider-opt "slug=tarpanpathak/helloworld"	

## build-docker 	: Compile the application in Docker.
build-docker:
	docker build -t $(DKR_IMG) .

## run-docker 	: Run the application in Docker.
run-docker:
	docker run -d $(DKR_IMG)

## save-docker	: Save the Docker image for later use.
save-docker:
	docker save $(DKR_IMG) > helloworld.tar

## load-docker	: Load the previously saved Docker image.
load-docker:
	docker load -i helloworld.tar

## tag-docker 	: Tag the Docker image.
tag-docker:
	docker image tag $(DKR_IMG) $(DKR_IMG_SEMREL)

## login-docker	: Login to the Docker registry.
login-docker:
	@echo ${DKR_REGISTRY_TOKEN} | docker login \
		${DKR_REGISTRY} -u ${DKR_REGISTRY_USER} --password-stdin

## push-docker 	: Publish the Docker image to the Docker registry.
push-docker:
	docker push $(DKR_IMG_SEMREL)

## logout-docker	: Logout of the Docker registry.
logout-docker:
	@docker logout $(DKR_REGISTRY)

## images-docker	: List all the Docker images.
images-docker: 
	@docker images $(DKR_IMG)

## debug-docker 	: Launch an interactive Docker container for debugging.
debug-docker:
	@docker run -it --rm --entrypoint=/bin/sh $(DKR_IMG)

## clean-docker 	: Cleanup the application Docker image/s.
clean-docker:
	docker rmi -f $(DKR_IMG)
	rm -rf helloworld.tar

## clean-release 	: Cleanup the release artifacts.
clean-release:
	rm -rf .semrel/

## clean-all 	: Cleanup all temporary artifacts.
clean-all:
	clean-docker
	clean-release
