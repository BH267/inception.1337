FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
	ca-certificates \
        php8.2-fpm \
        php8.2-mysql \
        php8.2-curl \
        php8.2-gd \
        php8.2-mbstring \
        php8.2-xml \
        php8.2-zip \
        wget \
        unzip && \
    rm -rf /var/lib/apt/lists/*

WORKDIR	/var/www/html

RUN wget https://wordpress.org/wordpress-6.5.tar.gz && \
    tar -xzf wordpress-6.5.tar.gz --strip-components=1 && \
    rm wordpress-6.5.tar.gz

COPY wp-config.php ./wp-config.php

RUN chown -R www-data:www-data /var/www/html

EXPOSE 9000

CMD ["php-fpm8.2", "--nodaemonize"]
