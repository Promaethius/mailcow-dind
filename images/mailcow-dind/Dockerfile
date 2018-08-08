FROM docker:dind

VOLUME /var/lib/docker /mailcow /mailcow-backup

RUN apk add --no-cache --upgrade grep git coreutils dcron curl py-pip
RUN pip install docker-compose
RUN pip install supervisor
RUN mkdir -p /var/log/cron && mkdir -m 0644 -p /var/spool/cron/crontabs && touch /var/log/cron/cron.log && mkdir -m 0644 -p /etc/cron.d
RUN curl -L https://github.com/mikefarah/yq/releases/download/2.1.1/yq_linux_amd64 -o /usr/local/bin/yq && chmod +x /usr/local/bin/yq

COPY ./cmd.sh /cmd.sh
COPY ./supervisor.conf /supervisor.conf

CMD /usr/bin/supervisord -n -c /supervisor.conf
