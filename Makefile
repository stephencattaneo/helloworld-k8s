IMAGE_NAME ?= local_image
CONTAINER_NAME ?= local_container
K8S_NAMESPACE ?= hwk8s

build:
	docker build -t ${IMAGE_NAME} .

docker-clean:
	-docker container ls -qa -f ancestor=${IMAGE_NAME} | xargs -I {} docker container rm {}
	-docker image ls -aq ${IMAGE_NAME} | xargs -I {} docker image rm {}

docker-run:
	docker run --name ${CONTAINER_NAME} -p 80:80 ${IMAGE_NAME}

create:
	kubectl apply -f config/namespace.yaml
	kubectl apply -f config/service.yaml
	kubectl apply -f config/deployment.yaml

run: build clean-pods

clean: clean-deployment clean-service clean-pods

clean-deployment:
	kubectl delete deployment -n ${K8S_NAMESPACE} helloworld

clean-service:
	kubectl delete service -n ${K8S_NAMESPACE} helloworld

clean-pods:
	kubectl delete --all pods -n ${K8S_NAMESPACE}

shell:
	docker exec -it ${CONTAINER_NAME} /bin/bash
