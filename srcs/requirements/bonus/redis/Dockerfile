FROM	debian:bookworm-slim
ENV	DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        redis-server && \
    rm -rf /var/lib/apt/lists/*

#RUN sed -i "s/^bind 127.0.0.1/bind 0.0.0.0/" /etc/redis/redis.conf

RUN mkdir -p /data

# for debugging
EXPOSE 6379

#CMD ["redis-server", "/etc/redis/redis.conf"]
CMD ["redis-server", "--protected-mode no", "--bind 0.0.0.0"]
