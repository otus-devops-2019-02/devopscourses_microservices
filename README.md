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



Подготовка
•	Клонируем новые исходники приложения:
mkdir backup
git mv src backup/
git clone https://github.com/express42/reddit.git src
rm -fdr src/.git
•	Добавляем в /src/post-py/Dockerfile установку пакетов gcc и musl-dev
•	Собираем все образы:
for i in ui post-py comment; do cd src/$i; bash docker_build.sh; cd -; done
Подготовка окружения
#!/bin/bash
export GOOGLE_PROJECT=docker-240808
docker-machine create --driver google \
    --google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
    --google-machine-type n1-standard-1 \
    --google-open-port 5601/tcp \
    --google-open-port 9292/tcp \
    --google-open-port 9411/tcp \
    logging

eval $(docker-machine env logging)

docker-machine ip logging

35.202.128.226

Создаем правило фаерволла:
gcloud compute firewall-rules create  kibana-default --allow tcp:5601  --target-tags=docker-machine  --description=" kibana"  --direction=INGRESS

Логирование Docker контейнеров
•	Создаем  docker-compose для системы логгирования в папке docker/
export USER_NAME=devopscourses

cat <<- EOF > docker/docker-compose-logging.yml
version: '3'
services:
  fluentd:
    image: \${USER_NAME}/fluentd
    ports:
      - "24224:24224"
      - "24224:24224/udp"

  elasticsearch:
    image: elasticsearch
    expose:
      - 9200
    ports:
      - "9200:9200"

  kibana:
    image: kibana
    ports:
      - "5601:5601"
EOF

docker-compose -f docker/docker-compose-logging.yml config
•	Fluentd.
mkdir -p logging/fluentd

cat <<- EOF > logging/fluentd/Dockerfile
FROM fluent/fluentd:v0.12
RUN gem install fluent-plugin-elasticsearch --no-rdoc --no-ri --version 1.9.5
RUN gem install fluent-plugin-grok-parser --no-rdoc --no-ri --version 1.0.0
ADD fluent.conf /fluentd/etc
EOF

cat <<- EOF > logging/fluentd/fluent.conf
<source>
  @type forward
  port 24224
  bind 0.0.0.0
</source>

<match *.**>
  @type copy
  <store>
    @type elasticsearch
    host elasticsearch
    port 9200
    logstash_format true
    logstash_prefix fluentd
    logstash_dateformat %Y%m%d
    include_tag_key true
    type_name access_log
    tag_key @log_name
    flush_interval 1s
  </store>
  <store>
    @type stdout
  </store>
</match>
EOF
•	Build Fluentd.
(cd logging/fluentd && docker build -t $USER_NAME/fluentd .)
•	Изменяем в .env  тэги на logging, запускаем приложения.
cd docker
docker-compose up -d
•	http://34.77.53.138:9292/
•	Добавляем драйвер логирования fluentd в post.
    logging:
      driver: "fluentd"
      options:
        fluentd-address: localhost:24224
        tag: service.post
•	Перезапускаем все сервисы.
•	Добавляем фильтр в fluentd:
<filter service.post>
  @type parser
  format json
  key_name log
</filter>
•	Rebuild&restart!
(cd ../logging/fluentd && docker build -t $USER_NAME/fluentd .)
docker-compose -f docker-compose-logging.yml up -d
Неструктруированные логи
•	Добавили драйвер логирования fluentd в ui.
    logging:
      driver: "fluentd"
      options:
        fluentd-address: localhost:24224
        tag: service.ui
•	Restart docker container ui.
•	Добавили regex фильтр.
<filter service.ui>
  @type parser
  format /\[(?<time>[^\]]*)\]  (?<level>\S+) (?<user>\S+)[\W]*service=(?<service>\S+)[\W]*event=(?<event>\S+)[\W]*(?:path=(?<path>\S+)[\W]*)?request_id=(?<request_id>\S+)[\W]*(?:remote_addr=(?<remote_addr>\S+)[\W]*)?(?:method= (?<method>\S+)[\W]*)?(?:response_status=(?<response_status>\S+)[\W]*)?(?:message='(?<message>[^\']*)[\W]*)?/'
  key_name log
</filter>
•	Пересоберём и перезапустим.
(cd ../logging/fluentd && docker build -t $USER_NAME/fluentd .)
docker-compose -f docker-compose-logging.yml up -d
•	Добавили ещё Гроку:
<filter service.ui>
  @type parser
  key_name log
  format grok
  grok_pattern %{RUBY_LOGGER}
</filter>

<filter service.ui>
  @type parser
  format grok
  grok_pattern service=%{WORD:service} \| event=%{WORD:event} \| request_id=%{GREEDYDATA:request_id} \| message='%{GREEDYDATA:message}'
  key_name message
  reserve_data true
</filter>
•	Rebuild&restart!
 (cd ../logging/fluentd && docker build -t $USER_NAME/fluentd .)
docker-compose -f docker-compose-logging.yml up -d
•	Добавляем  zipkin и переменную для включения zipkin в приложениях:
    environment:
      - ZIPKIN_ENABLED=${ZIPKIN_ENABLED}
•	Rebuild&restart!
docker-compose -f docker-compose.yml -f docker-compose-logging.yml down
docker-compose -f docker-compose.yml -f docker-compose-logging.yml up -d
•	Заходим в UI zipkin. http://34.77.53.138:9411/zipkin/


Lesson-25 HW kubernetes-1
 
-  Выполенен  туториал Kubernetes The Hard Way [https://github.com/kelseyhightower/kubernetes-the-hard-way]
- проверка создания подов 
for pod in comment mongo post ui; do \
 kubectl apply -f ../reddit/$pod-deployment.yml
done;
- 
NAME                                  READY   STATUS             RESTARTS   AGE
busybox-bd8fb7cbd-ffqjw               1/1     Running            0          39m
comment-deployment-5bfc574bb8-j7h72   1/1     Running            0          55s
mongo-deployment-78c45675cb-b48pt     0/1     ImagePullBackOff   0          54s
nginx-dbddb74b8-g5sl2                 1/1     Running            0          26m
post-deployment-6457776f46-7h2g9      1/1     Running            0          53s
ui-deployment-5c545f6c58-hgnp6        1/1     Running            0          52s
untrusted                             1/1     Running            0          9m36s
- Cleaning Up



KUBERNETES-2

Installing minikube.
•	Install Minikube via direct download:
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 \
  && chmod +x minikube
sudo install minikube /usr/local/bin
•	Запускаем minukube-кластер
minikube start
•	Проверяем командой kubectl get nodes
NAME       STATUS   ROLES    AGE    VERSION
minikube   Ready    master   105s   v1.15.0
•	Обновляем kubectrl.
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
sudo mv kubectl /usr/local/bin
•	Обновляем ui-deployment.yml:
---
apiVersion: apps/v1beta2
kind: Deployment
metadata:
  name: ui
  labels:
    app: reddit
    component: ui
spec:
  replicas: 3
  selector:
    matchLabels:
      app: reddit
      component: ui
  template:
    metadata:
      name: ui-pod
      labels:
        app: reddit
        component: ui
    spec:
      containers:
      - image: devopscourses/ui
        name: ui
•	Запускаем в minikube ui-компоненту.
kubectl apply -f ui-deployment.yml
•	Ждём несколько минут и проверяем командой kubectl get deployment. Доступно – 3 шт.
NAME   READY   UP-TO-DATE   AVAILABLE   AGE
ui     3/3     3            3           94s
•	Находим, при помощи selector, PODы приложения и пробрасываем порт.
kubectl get pods --selector component=ui
kubectl port-forward --address 0.0.0.0 ui-898f94546b-5znbt5 8080:9292
•	Проверяем работу: http://10.0.140.100:8080/
•	Обновляем comment-deployment.yml:
---
apiVersion: apps/v1beta2
kind: Deployment
metadata:
  name: comment
  labels:
    app: reddit
    component: comment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: reddit
      component: comment
  template:
    metadata:
      name: comment
      labels:
        app: reddit
        component: comment
    spec:
      containers:
      - image: devopscourses/comment
        name: comment
•	Запускаем в minikube компоненту.
kubectl apply -f comment-deployment.yml
•	Пробрасываем порты и Проверяем. http://10.0.140.100:8080/healthcheck
•	Обновляем post-deployment.yml:
---
apiVersion: apps/v1beta2
kind: Deployment
metadata:
  name: post-deployment
  labels:
    app: post
    component: post
spec:
  replicas: 3
  selector:
    matchLabels:
      app: post
      component: post
  template:
    metadata:
      name: post
      labels:
        app: post
        component: post
    spec:
      containers:
      - image: devopscourses/post
        name: post
•	Запускаем в Minikube компоненту.
kubectl apply -f post-deployment.yml
•	Пробрасываем порты и Проверяем. nc -v 10.0.140.100 5000
•	Обновляем mongo-deployment.yml:
---
apiVersion: apps/v1beta2
kind: Deployment
metadata:
  name: mongo
  labels:
    app: reddit
    component: mongo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: reddit
      component: mongo
  template:
    metadata:
      name: mongo
      labels:
        app: reddit
        component: mongo
    spec:
      containers:
      - image: mongo:3.2
        name: mongo
        volumeMounts:
        - name: mongo-persistent-storage
          mountPath: /data/db
      volumes:
      - name: mongo-persistent-storage
        emptyDir: {}
•	Запускаем в minikube компоненту.
kubectl apply -f mongo-deployment.yml
•	Создаем сервис comment-service.yml
---
apiVersion: v1
kind: Service
metadata:
  name: comment
  labels:
    app: reddit
    component: comment
spec:
  ports:
  - port: 9292
    protocol: TCP
    targetPort: 9292
  selector:
    app: reddit
    component: comment
•	Запускаем в minikube компоненту.
kubectl apply -f comment-service.yml
•	Проверяем kubectl describe service comment | grep Endpoints
•	Создаем сервис post-service.yml
---
apiVersion: v1
kind: Service
metadata:
  name: post
  labels:
    app: post
    component: post
spec:
  ports:
  - port: 5000
    protocol: TCP
    targetPort: 5000
  selector:
    app: post
    component: post
•	Запускаем в minikube компоненту.
kubectl apply -f post-service.yml
•	Проверяем kubectl exec -it ui-89dfhdgfg5f-4xt7 nslookup post
•	Создаем сервис mongodb-service.yml
---
apiVersion: v1
kind: Service
metadata:
  name: mongodb
  labels:
    app: reddit
    component: mongo
spec:
  ports:
  - port: 27017
    protocol: TCP
    targetPort: 27017
  selector:
    app: reddit
    component: mongo
•	Запускаем в Minikube компоненту.
kubectl apply -f mongodb-service.yml
•	Проверяем все сервисы kubectl get services --show-labels
•	Пробрасываем порт kubectl port-forward --address 0.0.0.0 ui-736h67236d-34saz 9292:9292
•	Проверяем http://10.0.140.100:9292/
•	В логах приложение ищет совсем другой адрес: comment_db, а не mongodb. Аналогично и сервис comment ищет post_db. Эти адреса заданы в их Dockerfile-ах в виде переменных окружения.
•	В Docker Swarm проблема доступа к одному ресурсу под разными именами решалась с помощью сетевых алиасов. В Kubernetes такого функционала нет. Мы эту проблему можем решить с помощью тех же Service-ов.
•	Сделаем service для БД comment-mongodb-service.yml:
---
apiVersion: v1
kind: Service
metadata:
  name: comment-db
  labels:
    app: reddit
    component: mongo
    comment-db: "true"
spec:
  ports:
  - port: 27017
    protocol: TCP
    targetPort: 27017
  selector:
    app: reddit
    component: mongo
    comment-db: "true"
•	Обновляем файл deployment для mongodb, чтобы новый Service смог найти необходимый POD.
---
apiVersion: apps/v1beta2
kind: Deployment
metadata:
  name: mongo
  labels:
    app: reddit
    component: mongo
    comment-db: "true"
spec:
  replicas: 1
  selector:
    matchLabels:
      app: reddit
      component: mongo
  template:
    metadata:
      name: mongo
      labels:
        app: reddit
        component: mongo
        comment-db: "true"
    spec:
      containers:
      - image: mongo:3.2
        name: mongo
        volumeMounts:
        - name: mongo-persistent-storage
          mountPath: /data/db
      volumes:
      - name: mongo-persistent-storage
        emptyDir: {}
•	Задаем pod-ам comment переменную окружения для обращения к базе:
---
apiVersion: apps/v1beta2
kind: Deployment
metadata:
  name: comment
  labels:
    app: reddit
    component: comment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: reddit
      component: comment
  template:
    metadata:
      name: comment
      labels:
        app: reddit
        component: comment
    spec:
      containers:
      - image: devopscourses/comment
        name: comment
        env:
        - name: COMMENT_DATABASE_HOST
          value: comment-db
•	Аналогично для post.
post-mongodb-service.yml
---
apiVersion: v1
kind: Service
metadata:
  name: post-db
  labels:
    app: reddit
    component: mongo
    comment-db: "true"
spec:
  ports:
  - port: 27017
    protocol: TCP
    targetPort: 27017
  selector:
    app: reddit
    component: mongo
    comment-db: "true"

post-deployment.yml
---
apiVersion: apps/v1beta2
kind: Deployment
metadata:
  name: post
  labels:
    app: post
    component: post
spec:
  replicas: 3
  selector:
    matchLabels:
      app: post
      component: post
  template:
    metadata:
      name: post
      labels:
        app: post
        component: post
    spec:
      containers:
      - image: devopscourses/post
        name: post
        env:
        - name: POST_DATABASE_HOST
          value: post-db
•	Пробрасываем порты kubectl port-forward --address 0.0.0.0 ui-736h67236d-34saz 9292:9292 и Проверяем. http://10.0.140.100:9292/
•	Обеспечиваем доступ к ui-сервису снаружи и создаем service для ui компоненты
---
apiVersion: v1
kind: Service
metadata:
  name: ui
  labels:
    app: reddit
    component: ui
spec:
  type: NodePort
  ports:
  - nodePort: 32092
    port: 9292
    protocol: TCP
    targetPort: 9292
  selector:
    app: reddit
    component: ui
•	Проверяем доступ через адрес виртуалки с minikube.
minikube service ui
•	Работает! http://192.168.100.110:32092/
•	Список расширений minikube minikube addons list
•	Объекты нашего dashboard kubectl get all -n kube-system --selector app=kubernetes-dashboard
•	Заходим в dashboard minikube service kubernetes-dashboard -n kube-system
Namespace
•	Создаем новый namespace - dev.
---
apiVersion: v1
kind: Namespace
metadata:
  name: dev
•	Добавляем информацию об окружении внутрь контейнера UI
        env:
        - name: ENV
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
Разворачиваем Kubernetes
•	Создаем кластер:
gcloud beta container --project "docker- 240828" clusters create "standard-cluster-1" \
  --zone "us-central1-a" --no-enable-basic-auth --cluster-version "1.12.8-gke.10" \
  --machine-type "n1-standard-1" --image-type "COS" --disk-type "pd-standard" --disk-size "20" \
  --scopes "https://www.googleapis.com/auth/devstorage.read_only",\
  "https://www.googleapis.com/auth/logging.write", \
  "https://www.googleapis.com/auth/monitoring",\
  "https://www.googleapis.com/auth/servicecontrol",\
  "https:// www.googleapis.com/auth/service.management.readonly",\
  "https://www.googleapis.com/auth/trace.append" \
  --num-nodes "2" --enable-cloud-logging --enable-cloud-monitoring --no-enable-ip-alias \
  --network "projects/docker-240828/global/networks/default" \
  --subnetwork "projects/docker-240828/regions/us-central1/subnetworks/default" \
  --addons HorizontalPodAutoscaling,HttpLoadBalancing --enable-autoupgrade --enable-autorepair
•	Подключаемся к кластеру (нажать Connect и скопировать команду, была проблемиа с сертификатом – из-за рассинхрона времени).
gcloud container clusters get-credentials standard-cluster-1 --zone us-central1-a --project docker-240828
•	Проверяем командой kubectl config current-context
•	Создаем dev namespace
kubectl apply -f reddit/dev-namespace.yml
•	Деплоим приложение в namespace dev:
kubectl apply -n dev -f .
•	Открываем Reddit для внешнего мира:
gcloud compute --project=docker-240828 firewall-rules create gce-cluster-reddit-app-access \
  --direction=INGRESS --priority=1000 --network=default --action=ALLOW --rules=tcp:30000-32767 \
  --source-ranges=0.0.0.0/0
•	Найходим внешний IP-адрес любой ноды из кластера kubectl get nodes -o wide
•	Найходим порт публикации сервиса ui
kubectl describe service ui -n dev | grep NodePort
•	Проверяем: http://34.67.107.181:32093/
•	В кластере включаем addon dashboadd.
•	Кластер загружается (неспешно).
•	Выполняем команду kubectl proxy.
•	Заходим по адресу: http://localhost:8001/ui
•	Нет доступа - нехватка прав.
•	Необходимо Service Account назначить роль с достаточными правами на просмотр информации о кластере В кластере уже есть объект ClusterRole с названием cluster-admin. Тот, кому назначена эта роль имеет полный доступ ко всем объектам кластера
•	Добавляем

