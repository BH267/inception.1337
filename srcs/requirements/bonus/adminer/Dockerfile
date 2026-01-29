FROM	debian:bookworm-slim
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        nginx \
        php8.2-fpm \
        php8.2-mysql \
	ca-certificates \
        wget && \
    rm -rf /var/lib/apt/lists/*

RUN sed -i 's/listen = \/run\/php\/php8.2-fpm.sock/listen = 9000/' /etc/php/8.2/fpm/pool.d/www.conf

RUN rm -f /etc/nginx/sites-enabled/default

RUN wget https://www.adminer.org/static/download/4.8.1/adminer-4.8.1.php -O /var/www/html/index.php

RUN echo "server { listen 8080; root /var/www/html; index index.php; location ~ \.php$ { fastcgi_pass 127.0.0.1:9000; fastcgi_index index.php; fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name; include fastcgi_params; } }" > /etc/nginx/conf.d/adminer.conf

CMD service php8.2-fpm start && nginx -g "daemon off;"
