FROM ubuntu
MAINTAINER mmiglier, marco.miglierina@icloud.com

RUN apt-get update && apt-get install -y \
    default-jre \
    curl \
    xz-utils

RUN cd /root \
    && curl -SL https://github.com/deib-polimi/tower4clouds/releases/download/v0.3.1/data-analyzer-0.3.1.tar.gz \
    | tar -xz

ENTRYPOINT ["java", "-jar", "/root/data-analyzer-0.3.1/tower4clouds-data-analyzer.jar"]
EXPOSE 8175
