FROM docker:dind

VOLUME /var/lib/docker /mailcow /mailcow-backup

RUN apk add --no-cache --upgrade grep git coreutils dcron curl py-pip
RUN pip install docker-compose
RUN mkdir -p /var/log/cron && mkdir -m 0644 -p /var/spool/cron/crontabs && touch /var/log/cron/cron.log && mkdir -m 0644 -p /etc/cron.d

COPY ./cmd.sh /cmd.sh

CMD /bin/sh /cmd.sh
