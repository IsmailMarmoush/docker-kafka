FROM openjdk:8-jre

ARG KAFKA=kafka_2.11-2.0.0

ENV KAFKA_HOME=/$KAFKA
ENV PATH=${PATH}:${KAFKA_HOME}/bin

RUN wget -q http://www-eu.apache.org/dist/kafka/2.0.0/$KAFKA.tgz
RUN tar xfz $KAFKA.tgz
RUN rm /$KAFKA.tgz
