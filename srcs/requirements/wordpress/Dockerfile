FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        php8.2-fpm \
        php8.2-mysql \
        php8.2-curl \
        php8.2-gd \
        php8.2-mbstring \
        php8.2-xml \
        php8.2-zip \
        php8.2-opcache \
        ca-certificates \
	mariadb-client \
        wget \
        unzip && \
    rm -rf /var/lib/apt/lists/*

RUN sed -i 's/listen = \/run\/php\/php8.2-fpm.sock/listen = 9000/' /etc/php/8.2/fpm/pool.d/www.conf && \
    sed -i 's/;listen.owner = www-data/listen.owner = www-data/' /etc/php/8.2/fpm/pool.d/www.conf && \
    sed -i 's/;listen.group = www-data/listen.group = www-data/' /etc/php/8.2/fpm/pool.d/www.conf

WORKDIR /var/www/html

RUN wget https://wordpress.org/wordpress-6.5.tar.gz && \
    tar -xzf wordpress-6.5.tar.gz --strip-components=1 && \
    rm wordpress-6.5.tar.gz

COPY wp-config.php ./wp-config.php

RUN chown -R www-data:www-data /var/www/html

RUN echo "log_errors = On" >> /etc/php/8.2/fpm/php.ini && \
    echo "error_log = /proc/self/fd/2" >> /etc/php/8.2/fpm/php.ini

EXPOSE 9000

CMD ["php-fpm8.2", "--nodaemonize"]
