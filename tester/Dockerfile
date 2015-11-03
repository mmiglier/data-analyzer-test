FROM ubuntu
MAINTAINER mmiglier, marco.miglierina@icloud.com

RUN apt-get update && apt-get install -y \
  curl

COPY test.bash /

CMD ./test.bash
