FROM	debian:bookworm-slim
ENV	DEBIAN_FRONTEND=noninteractive

RUN apt update -y && apt install -y openssl nginx \
        && rm -rf /var/lib/apt/lists/*

RUN rm -rf /usr/share/nginx/html/* \
        && rm -f /etc/nginx/sites-enabled/default

RUN echo 'server {' > /etc/nginx/sites-available/default && \
    echo '    listen 80 default_server;' >> /etc/nginx/sites-available/default && \
    echo '    listen [::]:80 default_server;' >> /etc/nginx/sites-available/default && \
    echo '    root /usr/share/nginx/html;' >> /etc/nginx/sites-available/default && \
    echo '    index index.html;' >> /etc/nginx/sites-available/default && \
    echo '    location / {' >> /etc/nginx/sites-available/default && \
    echo '        try_files $uri $uri/ =404;' >> /etc/nginx/sites-available/default && \
    echo '    }' >> /etc/nginx/sites-available/default && \
    echo '}' >> /etc/nginx/sites-available/default && \

    ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

COPY tools/index.html /usr/share/nginx/html/index.html

EXPOSE 80

CMD [ "nginx", "-g", "daemon off;" ]
