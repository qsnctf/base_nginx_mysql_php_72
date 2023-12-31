FROM php:7.2-fpm-alpine

LABEL Organization="qsnctf" Author="M0x1n <lqn@sierting.com>"

COPY files /tmp/

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.nju.edu.cn/g' /etc/apk/repositories \
    && apk add --update --no-cache tar nginx mysql mysql-client \
    && mkdir -p /run/nginx \
    && mkdir -p /var/log/nginx \
    # mysql ext
    && docker-php-source extract \
    && docker-php-ext-install mysqli pdo_mysql \
    && docker-php-source delete \
    # init mysql
    && mysql_install_db --user=mysql --datadir=/var/lib/mysql \
    && sh -c 'mysqld_safe &' \
    && sleep 5s \
    && mysqladmin -uroot password 'root' \
    # Fix: Update all root password \
    && mysql -uroot -proot -e "CREATE USER 'root'@'127.0.0.1' IDENTIFIED BY 'password'; GRANT ALL PRIVILEGES ON *.* TO 'root'@'127.0.0.1' WITH GRANT OPTION; FLUSH PRIVILEGES;" \
    && mysql -uroot -proot -e "SET PASSWORD FOR 'root'@'127.0.0.1' = PASSWORD('root');" \
    && mysql -uroot -proot -e "create user ping@'%' identified by 'ping';" \
    # configure file
    && mv /tmp/flag.sh /flag.sh \
    && mv /tmp/docker-entrypoint /usr/local/bin/docker-entrypoint \
    && chmod +x /usr/local/bin/docker-entrypoint \
    && mv /tmp/nginx.conf /etc/nginx/nginx.conf \
    && chown -R www-data:www-data /var/www/html \
    # clear
    && rm -rf /tmp/*

WORKDIR /var/www/html

COPY www /var/www/html/

EXPOSE 80

VOLUME ["/var/log/nginx"]

CMD ["/bin/sh", "-c", "docker-entrypoint"]