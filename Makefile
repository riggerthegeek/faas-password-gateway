DOCKER_IMG ?= "faas-password-gateway"
DOCKER_MANIFEST_URL ?= https://6582-88013053-gh.circle-artifacts.com/1/work/build/docker-linux-amd64
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
	@echo "Building latest Docker images"
	docker build --file ./Dockerfile --tag ${TAG_NAME}:linux-amd64-${VERSION_TYPE} .
	docker build --file ./Dockerfile.arm --tag ${TAG_NAME}:linux-arm-${VERSION_TYPE} .
.PHONY: build

download-docker:
	@echo "Downloading docker client with manifest command"
	curl -L ${DOCKER_MANIFEST_URL} -o ./docker
	chmod +x ./docker
	./docker version
.PHONY: download-docker

publish:
	./docker version || make download-docker

	@echo "Tagging Docker images as v${VERSION}"
	docker tag ${TAG_NAME}:linux-amd64-${VERSION_TYPE} ${TAG_NAME}:linux-amd64-${VERSION}
	docker tag ${TAG_NAME}:linux-amd64-${VERSION_TYPE} ${TAG_NAME}:linux-amd64-${VERSION_MAJOR}
	docker tag ${TAG_NAME}:linux-amd64-${VERSION_TYPE} ${TAG_NAME}:linux-amd64-${VERSION_MINOR}
	docker tag ${TAG_NAME}:linux-arm-${VERSION_TYPE} ${TAG_NAME}:linux-arm-${VERSION}
	docker tag ${TAG_NAME}:linux-arm-${VERSION_TYPE} ${TAG_NAME}:linux-arm-${VERSION_MAJOR}
	docker tag ${TAG_NAME}:linux-arm-${VERSION_TYPE} ${TAG_NAME}:linux-arm-${VERSION_MINOR}

	@echo "Pushing images to Docker"
	docker push ${TAG_NAME}:linux-amd64-${VERSION_TYPE}
	docker push ${TAG_NAME}:linux-amd64-${VERSION}
	docker push ${TAG_NAME}:linux-amd64-${VERSION_MAJOR}
	docker push ${TAG_NAME}:linux-amd64-${VERSION_MINOR}
	docker push ${TAG_NAME}:linux-arm-${VERSION_TYPE}
	docker push ${TAG_NAME}:linux-arm-${VERSION}
	docker push ${TAG_NAME}:linux-arm-${VERSION_MAJOR}
	docker push ${TAG_NAME}:linux-arm-${VERSION_MINOR}

	@echo "Create Docker manifests"
	./docker -D manifest create "${TAG_NAME}:${VERSION}" \
		"${TAG_NAME}:linux-amd64-${VERSION}" \
		"${TAG_NAME}:linux-arm-${VERSION}"
	./docker -D manifest annotate "${TAG_NAME}:${VERSION}" "${TAG_NAME}:linux-arm-${VERSION}" --os=linux --arch=arm --variant=v6
	./docker -D manifest push "${TAG_NAME}:${VERSION}"

	./docker -D manifest create "${TAG_NAME}:${VERSION_MAJOR}" \
		"${TAG_NAME}:linux-amd64-${VERSION_MAJOR}" \
		"${TAG_NAME}:linux-arm-${VERSION_MAJOR}"
	./docker -D manifest annotate "${TAG_NAME}:${VERSION_MAJOR}" "${TAG_NAME}:linux-arm-${VERSION_MAJOR}" --os=linux --arch=arm --variant=v6
	./docker -D manifest push "${TAG_NAME}:${VERSION_MAJOR}"

	./docker -D manifest create "${TAG_NAME}:${VERSION_MINOR}" \
		"${TAG_NAME}:linux-amd64-${VERSION_MINOR}" \
		"${TAG_NAME}:linux-arm-${VERSION_MINOR}"
	./docker -D manifest annotate "${TAG_NAME}:${VERSION_MINOR}" "${TAG_NAME}:linux-arm-${VERSION_MINOR}" --os=linux --arch=arm --variant=v6
	./docker -D manifest push "${TAG_NAME}:${VERSION_MINOR}"

	./docker -D manifest create "${TAG_NAME}:${VERSION_TYPE}" \
		"${TAG_NAME}:linux-amd64-${VERSION_TYPE}" \
		"${TAG_NAME}:linux-arm-${VERSION_TYPE}"
	./docker -D manifest annotate "${TAG_NAME}:${VERSION_TYPE}" "${TAG_NAME}:linux-arm-latest" --os=linux --arch=arm --variant=v6
	./docker -D manifest push "${TAG_NAME}:${VERSION_TYPE}"
.PHONY: publish
