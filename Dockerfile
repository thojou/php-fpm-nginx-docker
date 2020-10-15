FROM tjoussen/php7-fpm:latest

ENV fpm_conf /usr/local/etc/php-fpm.d/www.conf

RUN apt-get update -yqq && \
    apt-get install --no-install-recommends -yqq nginx supervisor && \
    rm -rf /var/lib/apt/lists/*
    
RUN addgroup --system nginx && \
    adduser --disabled-password --system --home /var/cache/nginx --shell /sbin/nologin --ingroup nginx nginx && \
    sed -i \
        -e "s/;catch_workers_output\s*=\s*yes/catch_workers_output = yes/g" \
        -e "s/pm.max_children = 5/pm.max_children = 4/g" \
        -e "s/pm.start_servers = 2/pm.start_servers = 3/g" \
        -e "s/pm.min_spare_servers = 1/pm.min_spare_servers = 2/g" \
        -e "s/pm.max_spare_servers = 3/pm.max_spare_servers = 4/g" \
        -e "s/;pm.max_requests = 500/pm.max_requests = 200/g" \
        -e "s/user = www-data/user = nginx/g" \
        -e "s/group = www-data/group = nginx/g" \
        -e "s/;listen.mode = 0660/listen.mode = 0666/g" \
        -e "s/;listen.owner = www-data/listen.owner = nginx/g" \
        -e "s/;listen.group = www-data/listen.group = nginx/g" \
        -e "s/listen = 127.0.0.1:9000/listen = \/var\/run\/php-fpm.sock/g" \
        -e "s/^;clear_env = no$/clear_env = no/" \
        ${fpm_conf}

RUN ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log

RUN mkdir -p /var/www/html/public

EXPOSE 80
WORKDIR /var/www/html

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/nginx-site.conf /etc/nginx/sites-available/default
COPY conf/supervisord.conf /etc/supervisord.conf
COPY entrypoint.sh /entrypoint.sh
COPY public/index.php /var/www/html/public/index.php

RUN chmod +x /entrypoint.sh && chown nginx:nginx /var/www/html -R
CMD ["/entrypoint.sh"]