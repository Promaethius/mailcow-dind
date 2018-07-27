FROM docker:dind

ENV COMPOSE=1.22.0

VOLUME /var/lib/docker

RUN apk add --no-cache --upgrade grep git coreutils
RUN curl -L https://github.com/docker/compose/releases/download/$COMPOSE/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose

COPY ./cmd.sh /cmd.sh

CMD /cmd.sh
