FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        wget \
        mariadb-server \
        mariadb-client && \
    rm -rf /var/lib/apt/lists/*


RUN wget -O /usr/local/bin/gosu https://github.com/tianon/gosu/releases/download/1.17/gosu-amd64 && \
    chmod +x /usr/local/bin/gosu

COPY conf/setup.sh /setup.sh

RUN chmod +x /setup.sh

EXPOSE 3306

ENTRYPOINT ["/setup.sh"]
