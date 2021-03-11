# Alpine Image for Nginx and PHP

# NGINX x ALPINE.
FROM nginx:1.19-alpine

# MAINTAINER OF THE PACKAGE.
LABEL original_maintainer="Neo Ighodaro <neo@creativitykills.co>"
LABEL maintainer="Lorenzo Leonardini <lorenzo@leonardini.dev>"

# INSTALL SOME SYSTEM PACKAGES.
RUN apk --update --no-cache add ca-certificates \
    bash \
    supervisor

# trust this project public key to trust the packages.
ADD https://dl.bintray.com/php-alpine/key/php-alpine.rsa.pub /etc/apk/keys/php-alpine.rsa.pub

# CONFIGURE ALPINE REPOSITORIES AND PHP BUILD DIR.
ARG PHP_VERSION=8.0
ARG ALPINE_VERSION=3.12
RUN echo "http://dl-cdn.alpinelinux.org/alpine/v${ALPINE_VERSION}/main" > /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/v${ALPINE_VERSION}/community" >> /etc/apk/repositories && \
    echo "https://dl.bintray.com/php-alpine/v${ALPINE_VERSION}/php-${PHP_VERSION}" >> /etc/apk/repositories

# INSTALL PHP AND SOME EXTENSIONS. SEE: https://github.com/codecasts/php-alpine
RUN apk add --no-cache --update php8-fpm \
    php8 \
    php8-openssl \
    php8-pdo \
    php8-pdo_mysql \
    php8-mbstring \
    php8-phar \
    php8-session \
    php8-dom \
    php8-ctype \
    php8-zlib && \
    ln -s /usr/bin/php8 /usr/bin/php

# CONFIGURE WEB SERVER.
RUN mkdir -p /var/www && \
    mkdir -p /run/php && \
    mkdir -p /run/nginx && \
    mkdir -p /var/log/supervisor && \
    mkdir -p /etc/nginx/sites-enabled && \
    mkdir -p /etc/nginx/sites-available && \
    rm /etc/nginx/nginx.conf && \
    rm /etc/php8/php-fpm.d/www.conf && \
    rm /etc/php8/php.ini

# INSTALL COMPOSER.
COPY --from=composer:1.10 /usr/bin/composer /usr/bin/composer

# ADD START SCRIPT, SUPERVISOR CONFIG, NGINX CONFIG AND RUN SCRIPTS.
ADD start.sh /start.sh
ADD config/supervisor/supervisord.conf /etc/supervisord.conf
ADD config/nginx/nginx.conf /etc/nginx/nginx.conf
ADD config/nginx/site.conf /etc/nginx/sites-available/default.conf
ADD config/php/php.ini /etc/php8/php.ini
ADD config/php-fpm/www.conf /etc/php8/php-fpm.d/www.conf
RUN chmod 755 /start.sh

# EXPOSE PORTS!
ARG NGINX_HTTP_PORT=80
ARG NGINX_HTTPS_PORT=443
EXPOSE ${NGINX_HTTPS_PORT} ${NGINX_HTTP_PORT}

# SET THE WORK DIRECTORY.
WORKDIR /var/www

# KICKSTART!
CMD ["/start.sh"]
