DOCKER_IMG ?= "faas-password-gateway"
DOCKER_USER ?= ""

VERSION = "0.1.0"
VERSION_MAJOR = "0"
VERSION_MINOR = "0.1"
VERSION_TYPE = "latest"

TAG_NAME = "${DOCKER_IMG}"
ifneq ($(DOCKER_USER), "")
TAG_NAME = "${DOCKER_USER}/${DOCKER_IMG}"
endif

build:
# 	Build the container
	docker build --build-arg NGINX_VERSION=${VERSION} --file ./Dockerfile --tag ${TAG_NAME}:${VERSION_TYPE} .
	docker build --file ./template/Dockerfile.armhf --tag ${TAG_NAME}:${VERSION_TYPE}-armhf .

	docker tag ${TAG_NAME}:${VERSION_TYPE} ${TAG_NAME}:${VERSION}
	docker tag ${TAG_NAME}:${VERSION_TYPE} ${TAG_NAME}:${VERSION_MAJOR}
	docker tag ${TAG_NAME}:${VERSION_TYPE} ${TAG_NAME}:${VERSION_MINOR}

	docker tag ${TAG_NAME}:${VERSION_TYPE} ${TAG_NAME}-armhf:${VERSION}-armhf
	docker tag ${TAG_NAME}:${VERSION_TYPE} ${TAG_NAME}-armhf:${VERSION_MAJOR}-armhf
	docker tag ${TAG_NAME}:${VERSION_TYPE} ${TAG_NAME}-armhf:${VERSION_MINOR}-armhf
.PHONY: build

publish:
	docker push ${TAG_NAME}:${VERSION_TYPE}
	docker push ${TAG_NAME}:${VERSION}
	docker push ${TAG_NAME}:${VERSION_MAJOR}
	docker push ${TAG_NAME}:${VERSION_MINOR}

	docker push ${TAG_NAME}:${VERSION_TYPE}-armhf
	docker push ${TAG_NAME}:${VERSION}-armhf
	docker push ${TAG_NAME}:${VERSION_MAJOR}-armhf
	docker push ${TAG_NAME}:${VERSION_MINOR}-armhf
.PHONY: publish
