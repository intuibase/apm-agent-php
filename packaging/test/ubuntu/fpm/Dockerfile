FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get -qq update \
    && apt-get -qq -y --no-install-recommends install apt-transport-https \
    && apt-get -qq -y --no-install-recommends install apt-utils \
        dpkg-sig \
        git \
        gnupg \
        gnupg2 \
        libzip-dev \
        logrotate \
        procps \
        rsyslog \
        unzip \
        wget \
        zlib1g-dev

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

COPY entrypoint.sh /bin

## Install the specific PHP version in addition with fpm and apache
ARG PHP_VERSION=7.2
ENV PHP_VERSION=$PHP_VERSION
RUN apt-get -qq -y --no-install-recommends install software-properties-common \
    && add-apt-repository ppa:ondrej/php \
    && apt-get -qq update \
    && apt-get -qq -y --no-install-recommends install \
        apache2 \
        php${PHP_VERSION} \
        libapache2-mod-fcgid \
        php${PHP_VERSION}-curl \
        php${PHP_VERSION}-fpm \
        php${PHP_VERSION}-mbstring \
        php${PHP_VERSION}-mysql \
        php${PHP_VERSION}-mysqli \
        php${PHP_VERSION}-posix \
        php${PHP_VERSION}-sqlite \
        php${PHP_VERSION}-xml \
    && rm -rf /var/lib/apt/lists/*

## Enabled the just installed PHP and the fcgi.
RUN update-alternatives --set php /usr/bin/php${PHP_VERSION} \
    && a2enmod proxy_fcgi setenvif

# Disable agent for auxiliary PHP processes to reduce noise in logs
ENV ELASTIC_APM_ENABLED=false

ENV TYPE=deb
ENV VERSION=
ENV GITHUB_RELEASES_URL=
WORKDIR /app

ENTRYPOINT ["/bin/entrypoint.sh"]
