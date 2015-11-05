FROM ubuntu
MAINTAINER mmiglier, marco.miglierina@icloud.com

RUN apt-get update && apt-get install -y \
    default-jdk \
    curl \
    xz-utils

RUN cd /root \
    && curl -SL https://github.com/deib-polimi/tower4clouds/releases/download/v0.3.1/data-analyzer-0.3.1.tar.gz \
    | tar -xz

RUN mkdir /tmp/results

ENTRYPOINT java -Xmx3500m -jar /root/data-analyzer-0.3.1/tower4clouds-data-analyzer.jar & \
  jstat -gc -t `pgrep java` 10000 > /tmp/results/`date +%Y%m%d-%H%M%S`-data-analyzer-memory.log
EXPOSE 8175
