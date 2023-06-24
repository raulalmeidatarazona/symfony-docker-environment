FROM php:8.2-fpm-alpine3.18 as base

ENV PROJECT_DIR /var/app
WORKDIR $PROJECT_DIR

ARG UID
RUN adduser -u ${UID} --disabled-password --gecos "" appuser
RUN mkdir /home/appuser/.ssh && chown -R appuser:appuser /home/appuser/
RUN echo "StrictHostKeyChecking no" >> /home/appuser/.ssh/config
RUN echo "alias sf=/var/app/bin/console" >> /home/appuser/.bashrc

RUN apk add --no-cache \
        bash \
        libzip-dev \
        openssl-dev \
        supervisor \
        postgresql-dev && \
    docker-php-ext-install -j$(nproc) \
            pdo_pgsql && \
    docker-php-ext-enable \
            pdo_pgsql
# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Install Symfony CLI
RUN curl -sS https://get.symfony.com/cli/installer | bash -s - --install-dir /usr/local/bin

# Install PHP-CS-FIXER
RUN wget https://cs.symfony.com/download/php-cs-fixer-v3.phar -O php-cs-fixer
RUN chmod a+x php-cs-fixer
RUN mv php-cs-fixer /usr/local/bin/php-cs-fixer

COPY docker/php/config/supervisor.conf /etc/supervisor/conf.d/supervisord.conf
COPY docker/php/config/www.conf /usr/local/etc/php-fpm.d/www.conf

# allow non-root users have home
RUN mkdir -p /opt/home
RUN chmod 777 /opt/home
ENV HOME /opt/home

ENV PATH $PROJECT_DIR/bin:$PROJECT_DIR/vendor/bin:$PATH
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

FROM base as dev
RUN apk add --no-cache git linux-headers && \
    apk add --no-cache --virtual .phpize_deps $PHPIZE_DEPS && \
    pecl install xdebug && \
    docker-php-ext-enable xdebug && \
    rm -rf /tmp/pear && \
    apk del .phpize_deps
COPY docker/php/config/php_dev.ini /usr/local/etc/php/php.ini
COPY --chown=www-data:www-data . /var/app

FROM base as result
ENV APP_ENV=prod
ENV APP_DEBUG=0
COPY ./ $PROJECT_DIR
RUN composer install --no-dev --classmap-authoritative --optimize-autoloader \
    && rm -rf \
        docker \
        tests \
        .env.test \
        .env.local \
        grumphp.yml \
        phpcs.xml.dist \
        phpstan.neon

FROM base as prod
RUN docker-php-ext-install opcache
COPY docker/php/config/php_prod.ini /usr/local/etc/php/php.ini
COPY --from=result $PROJECT_DIR ./
RUN chown -R www-data:www-data $PROJECT_DIR
USER www-data
