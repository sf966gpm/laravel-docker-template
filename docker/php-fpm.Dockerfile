FROM php:8.3-fpm-alpine

COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

RUN apk add --no-cache zip unzip tzdata shadow &&  \
    install-php-extensions sqlite3 pdo_mysql pdo_pgsql bcmath soap sockets redis gd zip

ENV TZ=Europe/Moscow

ARG USER_ID
ARG GROUP_ID
ARG USER
RUN addgroup -S -g ${GROUP_ID} ${USER} && adduser -S -G ${USER} -u ${USER_ID} ${USER}

ARG WORKDIR
WORKDIR ${WORKDIR}

RUN chown -R ${USER_ID}:${GROUP_ID} ${WORKDIR}

USER ${USER}
CMD ["/usr/bin/env", "php-fpm"]