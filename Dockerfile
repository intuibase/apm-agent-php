ARG PHP_VERSION=7.2
ARG SEL_DISTRO=buster
FROM php:${PHP_VERSION}-fpm-${SEL_DISTRO}

RUN apt-get -qq update \
    && apt-get -qq -y --no-install-recommends install \
        procps \
        rsyslog \
        curl \
        unzip \
        wget \
 && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install \
    mysqli \
    pcntl \
    pdo_mysql \
    opcache

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /app/agent/native/ext

ENV REPORT_EXIT_STATUS=1
ENV TEST_PHP_DETAILED=1
ENV NO_INTERACTION=1
ENV TEST_PHP_JUNIT=/app/build/junit.xml

# Disable agent for auxiliary PHP processes to reduce noise in logs
ENV ELASTIC_APM_ENABLED=false

# Create a link to extensions directory to make it easier accessible (paths are different between php releases)
RUN ln -s `find /usr/local/lib/php/extensions/ -name opcache.so | head -n1 | xargs dirname` /tmp/extensions
