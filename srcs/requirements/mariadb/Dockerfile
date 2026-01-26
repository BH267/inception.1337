FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        wget \
	ca-certificates \
        mariadb-server \
        mariadb-client && \
    rm -rf /var/lib/apt/lists/*

RUN wget -O /usr/local/bin/gosu https://github.com/tianon/gosu/releases/download/1.17/gosu-amd64 && \
    chmod +x /usr/local/bin/gosu

COPY conf/mariadb.cnf /etc/mysql/mariadb.conf.d/99-inception.cnf

COPY tools/setup.sh /setup.sh

RUN chmod +x /setup.sh

EXPOSE 3306

ENTRYPOINT ["/setup.sh"]
