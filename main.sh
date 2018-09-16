#!/bin/bash
set -e

network=docker_network
kafka_port=9092
kafka_image=ismailmarmoush/kafka

zookeeper_port=2181
zookeeper_image=zookeeper:3.5
zookeeper_id_label=zookeeper_id

build(){
    docker build -t $kafka_image .
}

bash(){
    docker exec -it
}

zookeeper(){
    #  ZOO_SERVERS: server.1=zoo1:2888:3888 server.2=zoo2:2888:3888 server.3=0.0.0.0:2888:3888
    id=$(( ( RANDOM % 10 )  + 1 ))
    set -x
    docker run -it \
        --network="$NETWORK" \
        -e ZOO_MY_ID=$id \
        --label $zookeeper_id_label=$id \
        -e ZOO_SERVERS="server.$id=0.0.0.0:2888:3888 $(zk_hosts $zookeeper_image :2888:3888)" \
        -e ZOO_STANDALONE_ENABLED=false \
        $zookeeper_image
}

kafka(){
    hosts=$(hosts $zookeeper_image ":$zookeeper_port")
    id=$(( ( RANDOM % 10 )  + 1 ))
    set -x
    docker run -it \
        --network="$NETWORK" \
        $kafka_image \
        /kafka/bin/kafka-server-start.sh \
           /kafka/config/server.properties \
           --override zookeeper.connect=$hosts \
           --override broker.id=$id
}

kafka_producer(){
    hosts=$(hosts $kafka_image ":$kafka_port")
    docker exec -it $name bash -c "/kafka/bin/kafka-console-producer.sh --broker-list $hosts --topic test"
}

kafka_consumer(){
    hosts=$(hosts $zookeeper_image ":$zookeeper_port")
    docker exec -it $name bash -c "/kafka/bin/kafka-console-consumer.sh --bootstrap-server $hosts --topic test --from-beginning"
}


####################################################################################################
# Utils
####################################################################################################

docker_network(){
    docker network create -d bridge $network
}

hosts(){
    local image_ancestor=$1
    local append=$2
    local hosts=$(container_name $image_ancestor | containers_ips | sed "s/$/$append,/")
    hosts=$(echo $hosts | sed -e "s/\s//" -e "s/,$//")
    echo $hosts
}

zk_hosts_old(){
    local image_ancestor=$1
    local append=$2
    local hosts=($(container_name $image_ancestor | containers_ips | sed "s/$/$append/"))
    result=()
    for idx in "${!hosts[@]}";
    do
        local zookeeper_id=$(container_label zookeeper $zookeeper_id_label)
        result+=("server.$zookeeper_id=${hosts[idx]}")
        #result+=("server.$idx=${hosts[idx]}")
    done
    echo "${result[@]}"
}

zk_hosts(){
    local image_ancestor=$1
    local append=$2
    local containers=($(container_name $image_ancestor ))
    result=()
    for idx in "${!containers[@]}";
    do
        cont_name=${containers[idx]}
        zookeeper_id=$(container_label $cont_name zookeeper_id)
        url=$(container_ip $cont_name)$append
        result+=("server.$zookeeper_id=$url")
        #result+=("server.$idx=${hosts[idx]}")
    done
    echo "${result[@]}"
}

container_label(){
    local container=$1
    label=$2
    docker inspect --format "{{ index .Config.Labels \"$label\"}}" $container
}

container_name(){
    input=$1
    docker ps --filter "ancestor=$input"  --format "{{.Names}}"
}

container_ip(){
    container=$1
    docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $container
}

containers_ips(){
    while read container; do
        docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $container
    done
}


$@