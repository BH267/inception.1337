FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends nginx && \
    rm -rf /var/lib/apt/lists/*

RUN rm -f /etc/nginx/sites-enabled/default

RUN mkdir -p /etc/nginx/ssl

COPY conf/nginx.conf /etc/nginx/nginx.conf

COPY tools/generate_cert.sh /generate_cert.sh

RUN chmod +x /generate_cert.sh

EXPOSE 443

ENTRYPOINT ["/generate_cert.sh"]
