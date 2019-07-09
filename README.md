Инсталляция Gitlab CI
•	Создаем виртуальную машину скриптом create_vm.sh:
#!/bin/bash
export GOOGLE_PROJECT=docker-240808
docker-machine create --driver google \
--google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
--google-machine-type n1-standard-1 \
--google-disk-size 60 \
--google-zone europe-west1-d \
gitlab-ci
•	Создаем правила firewall скриптом create_firewall_rules.sh:
#!/bin/bash
gcloud compute firewall-rules create gitlab-ci\
 --allow tcp:80,tcp:443 \
 --target-tags=docker-machine \
 --description="gitlab-ci connections http & https" \
 --direction=INGRESS
•	Настроим окружение для docker-machine:
eval $(docker-machine env gitlab-ci)
Подготавливаем окружение gitlab-ci
•	Login to vmachine:
docker-machine ssh gitlab-ci
•	Create tree and docker-compose.yml
sudo su
apt-get install -y docker-compose
mkdir -p /srv/gitlab/config /srv/gitlab/data /srv/gitlab/logs
cd /srv/gitlab/
cat << EOF > docker-compose.yml
web:
  image: 'gitlab/gitlab-ce:latest'
  restart: always
  hostname: 'gitlab.example.com'
  environment:
    GITLAB_OMNIBUS_CONFIG: |
      external_url 'http://$(curl ifconfig.me)'
  ports:
    - '80:80'
    - '443:443'
    - '2222:22'
  volumes:
    - '/srv/gitlab/config:/etc/gitlab'
    - '/srv/gitlab/logs:/var/log/gitlab'
    - '/srv/gitlab/data:/var/opt/gitlab'
EOF
Запускаем gitlab-ci
•	Login to vmachine:
docker-machine ssh gitlab-ci
•	Run docker-compose.yml
docker-compose up -d
•	Проверяем. http://34.76.185.68
•	Создали пароль пользователя, группу, проект.
•	Добавили ремоут в микросервисы.
•	git remote add gitlab  http://34.76.185.68/homework/example.git
git push gitlab gitlab-ci-1
•	Add pipeline definition in .gitlab-ci.yml file.
Run Runner.
•	Получили токен для runner:
Dklefwj489kdfhAd
•	На сервере gitlab-ci запустить раннер, выполнив:
docker run -d --name gitlab-runner --restart always \
-v /srv/gitlab-runner/config:/etc/gitlab-runner \
-v /var/run/docker.sock:/var/run/docker.sock \
gitlab/gitlab-runner:latest
•	Register runner:
docker exec -it gitlab-runner gitlab-runner register --run-untagged --locked=false
•	Добавим исходный код reddit в репозиторий:
git clone https://github.com/express42/reddit.git && rm -rf ./reddit/.git
git add reddit/
git commit -m “Add reddit app”
git push gitlab gitlab-ci-1
•	Добавили тест в пайплайн.
Dev окружение.
•	Изменили пайплайн и добавили окружение.
•	Создалось окружение dev
http://34.76.185.68/homework/example/environments
Staging и Production
•	Изменили пайплайн и добавили окружение.
•	Создались окружения stage and production.
•	Условия и ограничения.
  only:
    - /^\d+\.\d+\.\d+/
•	Без тэга пайплайн запустился без stage and prod.
•	Добавляем тег:
git commit -a -m 'test: #4 add logout button to profile page'
git tag 2.4.10
git push gitlab gitlab-ci-1 --tags
•	С тэгами запустился весь пайплайн.
Динамические окружения
•	Добавим job & branch  bugfix

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


###ПАМЯТКА##############################
$ export GOOGLE_PROJECT=_ваш-проект_

# Создать докер хост
docker-machine create --driver google \
    --google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
    --google-machine-type n1-standard-1 \
    --google-zone europe-west1-b \
    docker-host

# Настроить докер клиент на удаленный докер демон
eval $(docker-machine env docker-host)

# Переключение на локальный докер
eval $(docker-machine env --unset)

$ docker-machine ip docker-host

$ docker-machine rm docker-host






Мониторинг приложения и инфраструктуры
#Создаем виртуальную машину скриптом create_vm.sh 
#Создаем правила firewall скриптом create_firewall_rules.sh
#Configure local env
export GOOGLE_PROJECT=docker-240808

docker-machine create --driver google \
--google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
--google-machine-type n1-standard-1 \
--google-zone europe-west1-b \
docker-host

eval $(docker-machine env docker-host)
docker-machine ip docker-host
•	IP адрес хоста: 34.77.53.138
•	Разделяем docker compose файлы на приложение и мониторинг.
•	Добавляем cAdvisor в конфигурацию Prometheus.
•	Пересоберем образ Prometheus с обновленной конфигурацией:
export USER_NAME=devopscourses
cd monitoring/prometheus
docker build -t $USER_NAME/prometheus .
•	Запустим сервисы:
cd docker
docker-compose up -d
docker-compose -f docker-compose-monitoring.yml up -d
•	Создаем правила файрвола VPC:
gcloud compute firewall-rules create prometheus-default --allow tcp:9090
gcloud compute firewall-rules create puma-default --allow tcp:9292
gcloud compute firewall-rules create cadvisor-default --allow tcp:8080
•	Приложение и мониторинг работают: Приложение http://34.77.53.138:9292/ Prometheushttp://34.77.53.138:9090/graph cAdvisor http://34.77.53.138:8080/containers/ http://34.77.53.138:8080/metrics
•	Добавляем сервис Grafana для визуализации метрик Prometheus.
•	Создаем правило файрвола VPC для Grafana:
gcloud compute firewall-rules create grafana-default --allow tcp:3000
•	Графана заработала!!! http://34.77.53.138:3000/login
•	Подключаем дашборд:
mkdir -p monitoring/grafana/dashboards
wget 'https://grafana.com/api/dashboards/893/revisions/5/download' -O monitoring/grafana/dashboards/DockerMonitoring.json
•	Добавляем информацию о post-сервисе в конфигурацию Prometheus.
•	Пересобираем Prometheus:
cd monitoring/prometheus
docker build -t $USER_NAME/prometheus .
•	Пересоздаем нашу Docker инфраструктуру мониторинга:
docker-compose -f docker-compose-monitoring.yml down
docker-compose -f docker-compose-monitoring.yml up -d
•	Добавили графики в dashboard с запросами:
rate(ui_request_count{http_status=~"^[45].*"}[1m])
rate(ui_request_count{http_status=~".*"}[1m])
•	Добавили графики в дашборд с запросами:
histogram_quantile(0.95, sum(rate(ui_request_response_time_bucket[5m])) by (le))
Мониторинг бизнесс-логики
•	Добавляем графики в dashboard с запросами:
rate(comment_count[1h])
rate(post_count[1h])
Alerting
#Конфигурируем alertmanager для prometheus:
mkdir monitoring/alertmanager
cat << EOF > monitoring/alertmanager/Dockerfile
FROM prom/alertmanager:v0.14.0
ADD config.yml /etc/alertmanager/
EOF

cat <<- EOF > monitoring/alertmanager/config.yml
global:
  slack_api_url: https://hooks.slack.com/services/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

route:
  receiver: 'slack-notifications'

receivers:
- name: 'slack-notifications'
  slack_configs:
  - channel: '#konstantin_semirov' 
EOF
# Билдим alertmanager
USER_NAME=devopscourses
docker build -t $USER_NAME/alertmanager .
•	Добавляем новый сервис в docker-compose файла мониторинга.
•	Создаем файл alerts.yml
cat <<- EOF > monitoring/prometheus/alerts.yml
groups:
  - name: alert.rules
    rules:
    - alert: InstanceDown
      expr: up == 0
      for: 1m
      labels:
        severity: page
      annotations:
        description: '{{ $labels.instance }} of job {{ $labels.job }} has been down for more than 1 minute'
        summary: 'Instance {{ $labels.instance }} down'
EOF
•	Дабавляем в Dockerfile Prometheus-а
ADD alerts.yml /etc/prometheus/
•	Добавляем информацию о правилах, в конфиг Prometheus prometheus.yml
rule_files:
  - "alerts.yml"

alerting:
  alertmanagers:
  - scheme: http
    static_configs:
    - targets:
      - "alertmanager:9093"
•	ReBuild prometheus
USER_NAME=devopscourses
docker build -t $USER_NAME/prometheus .
•	Restart monitoring dockers:
docker-compose -f docker-compose-monitoring.yml down
docker-compose -f docker-compose-monitoring.yml up -d
•	Создаем правила фаервола VPC:
gcloud compute firewall-rules create alertmanager-default --allow tcp:9093
•	Проверяем ссылке: http://34.77.53.138:9093/#/alerts
•	Пушим образы в GitHub:
docker push $USER_NAME/ui
docker push $USER_NAME/comment
docker push $USER_NAME/post
docker push $USER_NAME/prometheus
docker push $USER_NAME/alertmanager

