build:
	for version in $(PHP_VERSIONS); do \
		sed 's/%VERSION%/'"$$version"'/' Dockerfile > Dockerfile.$$version ; \
		docker build --pull --no-cache -t $(CI_COMMIT_SHA) -f Dockerfile.$$version . ; \
		docker tag $(CI_COMMIT_SHA) $(CI_REGISTRY_IMAGE):$$version ; \
		docker push $(CI_REGISTRY_IMAGE):$$version; \
	done
