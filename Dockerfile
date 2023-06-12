ARG PHP_VERSION=7.2
FROM php:${PHP_VERSION}-fpm

RUN apt-get -qq update \
    && apt-get -qq -y --no-install-recommends install \
        procps \
        rsyslog \
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

# Patch run-tests.php to handle SKIPIF correctly in tests with agent debug logs enabled
RUN find /usr/local/lib/php/ -name run-tests.php | xargs sed -i 's#if (!strncasecmp(\x27skip\x27, ltrim(\$output), 4))#if (!strncasecmp(\x27skip\x27, ltrim(\$output), 4) || strstr(\$output, \x27ElasticApmSkipTest\x27))#g'

RUN find /usr/local/lib/php/ -name run-tests.php | xargs sed -i 's#system_with_timeout("\$extra \$php \$pass_options -q \$ini_settings \$no_file_cache -d display_errors=0 \\"\$test_skipif\\"", \$env)#system_with_timeout("\$extra \$php \$pass_options -q \$ini_settings \$no_file_cache -d display_errors=0 \\"\$test_skipif\\" 2>\&1", \$env)#g'