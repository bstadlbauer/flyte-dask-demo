WORKFLOW_VERSION = $(shell date +%F-%H-%M-%S)
# Assign version to make sure it does not change again
WORKFLOW_VERSION := ${WORKFLOW_VERSION}
WORKFLOW_DOCKER_IMAGE = dask-plugin-dev:${WORKFLOW_VERSION}

.PHONY: requirements
requirements:
	pip-compile requirements.in --output-file requirements.txt

.PHONY: build
build:
	docker build -t ${WORKFLOW_DOCKER_IMAGE} -f ./Dockerfile .  

.PHONY: serialize
serialize: build
	rm -rf ./workflows
	mkdir workflows
	docker run \
		--rm \
		-v $(PWD)/demo:/src/demo \
		-v $(PWD)/workflows:/src/workflows \
		--workdir /src \
	    ${WORKFLOW_DOCKER_IMAGE} \
	    pyflyte --pkgs demo package --fast --image ${WORKFLOW_DOCKER_IMAGE} -o /src/workflows/flyte-package.tgz
	tar zxvf ./workflows/flyte-package.tgz -C ./workflows/
	rm ./workflows/flyte-package.tgz

.PHONY: register
register: serialize
	flytectl -p dask-plugin -d development register files --version ${WORKFLOW_VERSION} $(PWD)/workflows/*
