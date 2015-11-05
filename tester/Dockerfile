FROM ubuntu
MAINTAINER mmiglier, marco.miglierina@icloud.com

RUN apt-get update && apt-get install -y \
  curl

COPY test.bash /
RUN mkdir /tmp/results

CMD ./test.bash
