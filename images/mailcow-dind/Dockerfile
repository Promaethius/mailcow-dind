FROM docker:dind

ENV COMPOSE=1.22.0

VOLUME /var/lib/docker /mailcow /mailcow-backup

RUN apk add --no-cache --upgrade grep git coreutils dcron curl bash
RUN mkdir -p /var/log/cron && mkdir -m 0644 -p /var/spool/cron/crontabs && touch /var/log/cron/cron.log && mkdir -m 0644 -p /etc/cron.d
RUN curl -L https://github.com/docker/compose/releases/download/$COMPOSE/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose

COPY ./cmd.sh /cmd.sh

CMD /bin/sh /cmd.sh
