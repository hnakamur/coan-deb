DOCKER_IMAGE_NAME=coan-deb
COAN_DEB_VER=6.0.1-1hnakamur1ubuntu22.04
NO_CACHE=--no-cache

build:
	docker build $(NO_CACHE) --progress=plain -t $(DOCKER_IMAGE_NAME) . 2>&1 | tee coan_$(COAN_DEB_VER)_amd64.build.log
	zstd --rm --force -19 coan_$(COAN_DEB_VER)_amd64.build.log
	docker run --rm -v .:/dist --entrypoint=cp $(DOCKER_IMAGE_NAME) /work/install/coan_$(COAN_DEB_VER)_amd64.deb /dist/

.PHONY: bulid
