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

