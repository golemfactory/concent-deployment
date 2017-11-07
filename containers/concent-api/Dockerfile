FROM debian:stretch

COPY install-dependencies.sh        /tmp/
RUN  /tmp/install-dependencies.sh

ADD concent-api.tar                 /srv/http/
COPY install-concent-api.sh         /tmp/
COPY concent-api-manage.sh          /usr/local/bin/
COPY run-gunicorn.sh                /usr/local/bin/
RUN  /tmp/install-concent-api.sh

CMD ["/usr/local/bin/run-gunicorn.sh"]
