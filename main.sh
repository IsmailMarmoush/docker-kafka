#!/bin/bash
set -e

network=docker_network
kafka_port=9092
zookeeper_port=2181

build(){
    docker build -t ismailmarmoush/kafka .
}

run(){
    docker run -it \
        --network="$NETWORK" \
        ismailmarmoush/kafka
}

bash(){
    docker exec -it
}

zookeeper(){
    docker run -it \
        --network="$NETWORK" \
        zookeeper
}

####################################################################################################
# Utils
####################################################################################################

docker_network(){
    docker network create -d bridge $network
}

get_ip(){
    container=$1
    docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $container
}

get_name(){
    ancestor=$1
    docker ps --filter "ancestor=$ancestor"  --format "{{.Names}}"
}

$@