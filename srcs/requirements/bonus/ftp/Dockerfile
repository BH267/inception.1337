FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        vsftpd \
	ftp \
        libpam-pwdfile && \
    rm -rf /var/lib/apt/lists/*

RUN useradd -m -d /var/www/html -s /bin/bash wpuser

COPY ./tools/setup.sh /setup.sh
RUN chmod +x /setup.sh

EXPOSE 21 21100-21110

ENTRYPOINT ["/setup.sh"]
