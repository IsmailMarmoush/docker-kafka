#!/bin/bash
set -e

network=docker_network
kafka_port=9092
kafka_image=ismailmarmoush/kafka

zookeeper_port=2181
zookeeper_image=zookeeper

build(){
    docker build -t $kafka_image .
}

bash(){
    docker exec -it
}

zookeeper(){
    docker run -it \
        --network="$NETWORK" \
        zookeeper
}

kafka(){
    hosts=$(get_hosts $zookeeper_image $zookeeper_port)
    id=$(( ( RANDOM % 10 )  + 1 ))
    echo "id: $id"
    docker run -it \
        --network="$NETWORK" \
        $kafka_image \
        /kafka/bin/kafka-server-start.sh \
           /kafka/config/server.properties \
           --override zookeeper.connect=$hosts \
           --override broker.id=$id
}

kafka_producer(){
    hosts=$(get_hosts $kafka_image $kafka_port)
    docker exec -it $name bash -c "/kafka/bin/kafka-console-producer.sh --broker-list $hosts --topic test"
}

kafka_consumer(){
    hosts=$(get_hosts $zookeeper_image $zookeeper_port)
    docker exec -it $name bash -c "/kafka/bin/kafka-console-consumer.sh --bootstrap-server $hosts --topic test --from-beginning"
}


####################################################################################################
# Utils
####################################################################################################

docker_network(){
    docker network create -d bridge $network
}

get_hosts(){
    image_ancestor=$1
    port=$2
    hosts=$(get_container_name $image_ancestor | get_container_ips | sed "s/$/:$port,/")
    hosts=$(echo $hosts | sed -e "s/\s//" -e "s/,$//")
    echo $hosts
}

get_container_ips(){
    while read input; do
        docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $input
    done
}

get_container_name(){
    input=$1
    docker ps --filter "ancestor=$input"  --format "{{.Names}}"
}

$@