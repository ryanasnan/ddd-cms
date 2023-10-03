FROM php:7.4.33-fpm

RUN apt-get update && apt-get install -y \
    build-essential \
    locales \
    libzip-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    unzip \
    zip \
    curl

RUN apt-get install -y \
    ant

# Install php extensions for laravel
RUN docker-php-ext-install bcmath pdo_mysql exif pcntl zip

RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

COPY config/php.ini /etc/php7/php.ini
COPY config/php-fpm.conf /etc/php7/php-fpm.conf
COPY config/xdebug.ini /etc/php7/conf.d/xdebug.ini

# Install composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php -r "if (hash_file('sha384', 'composer-setup.php') === 'e21205b207c3ff031906575712edab6f13eb0b361f2085f1f1237b7126d785e826a450292b6cfd1d64d92e6563bbde02') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
RUN php composer-setup.php --version=2.2.9 --install-dir=/usr/local/bin --filename=composer
RUN php -r "unlink('composer-setup.php');"

RUN echo 'root:docker' | chpasswd

# Set working directory
WORKDIR /app

# create user
RUN useradd -ms /bin/bash -u 1000 -U host

USER host

# Expose port 9000 and start php-fpm server
EXPOSE 9000
CMD ["php-fpm"]