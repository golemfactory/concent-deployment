FROM debian:stretch-slim

COPY install-dependencies.sh /tmp/
RUN /tmp/install-dependencies.sh

COPY send_transaction.py /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/send_transaction.py"]
