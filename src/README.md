devopscourses_microservices

- docker run -ti --rm --network none joffotron/docker-net-tools -c ifconfig
- docker run -ti --rm --network host joffotron/docker-net-tools -c ifconfig
- docker-machine ssh docker-host ifconfig
- docker run --network host -d nginx
- docker kill $(docker ps -q) #kill all started containers
- #check running net-namespaces with command docker-machine ssh docker-host sudo ip netns
- # use ip netns exec for execute command in choosed namespace

###bridge network driver#####

- docker network create reddit --driver bridge

- docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db mongo:latest
  docker run -d --network=reddit --network-alias=post devopscourses/post:1.0
  docker run -d --network=reddit --network-alias=comment  devopscourse/comment:1.0
  docker run -d --network=reddit -p 9292:9292 devopscourse/ui:1.0
  
### sep-te network to front and ens
docker network create back_net --subnet=10.0.2.0/24
docker network create front_net --subnet=10.0.1.0/24

- docker run -d --network=back_net --name mongo_db --network-alias=post_db --network-alias=comment_db mongo:latest
  docker run -d --network=back_net --name post devopscourses/post:1.0
  docker run -d --network=back_net --name comment  devopscourse/comment:1.0
  docker run -d --network=front_net -p 9292:9292 devopscourse/ui:1.0

##not working, add containers to second nets
docker network connect front_net post
docker network connect front_net comment

## all fine

###install bridge driver on docker host ############
- sudo apt-get update && sudo apt-get install bridge-utils
- docker network ls
- brctl show ## list bridge
- iptables -nvL -t nat ### list iptables
- pgrep -a docker-proxy ### list proxy

- create docker-compose.yml
- export USERNAME=devopscourses

-add .env

chenge progect name: COMPOSE_PROJECT_NAME








