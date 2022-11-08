## -----------------------------------------------------------------------------
## Make targets for building, publishing, and deploying simplehttpserver.
## -----------------------------------------------------------------------------

# Dynamic variables - passed at runtime
DKR_REGISTRY?=ghcr.io
DKR_REGISTRY_TOKEN?=${GH_PAT_ADMIN}
DKR_REGISTRY_USER?=${GH_USER}
DKR_REPOSITORY?=tarpanpathak/${APP}
DKR_TAG?=${BRANCH}
DKR_IMG?=${DKR_REGISTRY}/${DKR_REPOSITORY}:${DKR_TAG}

# Static variables
BRANCH=$(shell git rev-parse --abbrev-ref HEAD)
COMMIT=$(shell git rev-parse --short HEAD)
CWD=$(shell pwd)
APP=$(shell basename "${CWD}")
GO_VERSION=1.19.1

# Avoid name collisions between targets and files.
.PHONY: help build run test \
	build-docker run-docker tag login push logout \
	images debug clean

# A target to format and present all supported targets with their descriptions.
help : Makefile
		@sed -n 's/^##//p' $<

## build-local 		: Compile the application natively.
build-local:
	go build -o ${APP}

## run-local 		: Run the application natively.
run-local:
	./${APP}

## test-local		: Run unit tests natively.
test-local:
	go test -v -race ./...

## build-docker 		: Compile the application in Docker.
build-docker:
	docker build --build-arg GO_VERSION=$(GO_VERSION) -t $(DKR_IMG) .

## run-docker 		: Run the application in Docker.
run-docker:
	docker run -d $(DKR_IMG)

## login-docker		: Login to the Docker registry.
login-docker:
	@echo ${DKR_REGISTRY_TOKEN} | docker login \
		${DKR_REGISTRY} -u ${DKR_REGISTRY_USER} --password-stdin

## push-docker 		: Push the Docker image to the Docker registry.
push-docker:
	docker push $(DKR_IMG)

## logout-docker		: Logout of the Docker registry.
logout-docker:
	@docker logout $(DKR_REGISTRY)

## images-docker		: List all the Docker images.
images-docker: 
	@docker images $(DKR_IMG)

## debug-docker 		: Launch an interactive Docker container for debugging.
debug-docker:
	@docker run -it --rm --entrypoint=/bin/sh $(DKR_IMG)

## clean 			: Cleanup temporary files.
clean:
	docker rmi -f $(DKR_IMG)
