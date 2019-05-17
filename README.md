# devopscourses_microservices
devopscourses microservices repository
- Create project ID: docker-240808
- Launch gcloud init
- Create auth file ($HOME/.config/gcloud/application_default_credentials.json) for docker-machine:
- gcloud auth application-default login
- export GOOGLE_PROJECT=docker-239319
- Ceate VMachine: 
"docker-machine create --driver google \
--google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
--google-machine-type n1-standard-1 \
--google-zone europe-west1-b docker-host"

- eval $(docker-machine env docker-host)
- wget "https://raw.githubusercontent.com/express42/otus-snippets/master/hw-15/mongod.conf" -O mongod.conf
- wget "https://raw.githubusercontent.com/express42/otus-snippets/master/hw-15/start.sh" -O start.sh
- echo DATABASE_URL=127.0.0.1 > db_config
- wget "https://raw.githubusercontent.com/express42/otus-snippets/master/hw-15/Dockerfile" -O Dockerfile
- docker build -t reddit:latest .
- docker images -a
- docker run --name reddit -d --network=host reddit:latest
- docker-machine ls
- Create VPC rule for puma:
"--allow tcp:9292 \
--target-tags=docker-machine \
--description="Allow PUMA connections" \
--direction=INGRESS
"
DOCKER HUB REGISTRATION
Login succeeded
docker tag reddit:latest devopscourses/otus-reddit:1.0
docker push devopscourse/otus-reddit:1.0
docker run --name reddit -d -p 9292:9292 avzhalnin/otus-reddit:1.0
It works!!! http://localhost:9292/
docker inspect avzhalnin/otus-reddit:1.0 -f '{{.ContainerConfig.Cmd}}' [/bin/sh -c #(nop) CMD ["/start.sh"]]
docker exec -it reddit bash

DESTROY
docker-machine rm docker-host
eval $(docker-machine env --unset)
