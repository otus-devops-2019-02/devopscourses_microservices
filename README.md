# devopscourses_microservices
devopscourses microservices repository

Настройка интеграции с travis-ci
git clone https://github.com/otus-devops-2019-02/devopscourses_microservices.git
cd devopscourses_microservices/
git checkout -b docker-1
mkdir .github
wget http://bit.ly/otus-pr-template -O .github/PULL_REQUEST_TEMPLATE.md
wget https://bit.ly/otus-travis-yaml-2019-02 -O .travis.yml
git add PULL_REQUEST_TEMPLATE.md ../.travis.yml
git commit -m 'Add PR template and travis checks'
git push -u origin docker-1
Go to slack channel DevOps team\andrey_zhalnin and say:
'/github subscribe Otus-DevOps-2019-02/<GITHUB_USER>_infra commits:all'

Docker
Install docker-machine
base=https://github.com/docker/machine/releases/download/v0.16.0 &&
curl -L $base/docker-machine-$(uname -s)-$(uname -m) >/tmp/docker-machine &&
sudo install /tmp/docker-machine /usr/local/bin/docker-machine
sudo bash. Т.к. докер не запускается без рута.
docker run -it ubuntu:16.04 /bin/bash
docker ps -a --format "table {{.ID}}\t{{.Image}}\t{{.CreatedAt}}\t{{.Names}}"
docker run -dt nginx:latest
docker kill $(docker ps -q)
docker rm $(docker ps -a -q)
