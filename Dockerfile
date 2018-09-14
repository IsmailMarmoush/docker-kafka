FROM openjdk:8-jre

ARG kafka=kafka_2.11-2.0.0.tgz

MAINTAINER ismailmarmoush

ENV KAFKA_HOME=/kafka

ENV PATH=${PATH}:${KAFKA_HOME}/bin

RUN wget http://www-eu.apache.org/dist/kafka/2.0.0/$kafka
RUN tar xfz $kafka -C $KAFKA_HOME
RUN rm /$kafka

CMD ["echo hi"]