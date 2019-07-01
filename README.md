
#Создаем виртуальную машину скриптом create_vm.sh
#Создаем правила firewall скриптом create_firewall_rules.sh
# configure local env
eval $(docker-machine env docker-host)
#check ext ip addre vm
docker-machine ip docker-host
#Запуск Prometheus
docker run --rm -p 9090:9090 -d --name prometheus prom/prometheus:v2.1.0
#Заходим в UI http://34.77.53.138:9090/graph
Stop container! docker stop prometheus

#Изменяем структуру директорий
cd /opt/containers/otus/devopscourses_microservices
mkdir docker
git mv docker-monolith docker
git mv src/docker-compose.yml docker
git mv src/.env.example docker
mv src/docker-compose.* docker
mv src/.env docker
mkdir monitoring
echo .env > docker/.gitignore

#Создание Docker образа
Create Dockerfile
mkdir docker/prometheus
cat << EOF > docker/prometheus/Dockerfile
FROM prom/prometheus:v2.1.0
ADD prometheus.yml /etc/prometheus/
EOF
Create prometheus.yml
---
global:
  scrape_interval: '5s'

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets:
        - 'localhost:9090'

  - job_name: 'ui'
    static_configs:
      - targets:
        - 'ui:9292'

  - job_name: 'comment'
    static_configs:
      - targets:
        - 'comment:9292'

#В директории prometheus билдим  Docker образ:
export USER_NAME=devopscourses
docker build -t $USER_NAME/prometheus .
Build dockers
cd opt/containers/otus/devopscourses_microservices
for i in ui post-py comment; do cd src/$i; bash docker_build.sh; cd -; done
All work good. http://34.77.53.138:9292/ http://34.77.53.138:9090/graph
Add new service node-exporter
Add new target for prometheus: node-exporter

#Пушим образы в dockerhub:
docker login
for i in ui comment post prometheus; do echo $i; docker push devopscourses/$i; done

###Не работали healthchekи при поднятых таргетах - косяки в настройки сети докера, нужно правильно настраивать алиасы\либо вообще без них

