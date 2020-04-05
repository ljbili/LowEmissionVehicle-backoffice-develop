FROM php:7.3-apache

# Install the PHP extensions I need for my personal project (gd, mbstring, opcache)
RUN apt-get update && apt-get install -y libpng-dev libzip-dev zip libjpeg-dev vim sudo libpq-dev git unzip wget autoconf dpkg-dev openssl  file libc-client-dev libc-dev make pkg-config re2c  \
	&& rm -rf /var/lib/apt/lists/* \
	&& docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
	&& docker-php-ext-install gd mbstring opcache pdo zip 
RUN apt-get update && apt-get install -y apt-utils adduser curl nano debconf-utils bzip2 dialog locales-all zlib1g-dev libicu-dev g++ gcc locales make build-essential

RUN a2enmod rewrite
RUN a2enmod expires
RUN a2enmod mime
RUN a2enmod filter
RUN a2enmod deflate
RUN a2enmod proxy_http
RUN a2enmod headers
RUN a2enmod php7

RUN curl -sS https://getcomposer.org/installer | php -- --filename=composer --install-dir=/usr/local/bin
#RUN curl -sL https://deb.nodesource.com/setup | bash -
ADD php.ini /usr/local/etc/php/

# Clean after install
RUN apt-get autoremove -y && apt-get clean all

# Configuration for Apache
RUN rm -rf /etc/apache2/sites-enabled/000-default.conf
ADD 000-default.conf /etc/apache2/sites-available/
RUN ln -s /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-enabled/
RUN a2enmod rewrite

EXPOSE 80
RUN mkdir /var/www/html/public

# Change website folder rights and upload your website
RUN chown -R www-data:www-data /var/www/html/*
ADD ./  /var/www/html

# Change working directory
WORKDIR /var/www/html

# Install and update php (rebuild into vendor folder)
#RUN composer install
#RUN composer update

# Change your local - here it's in french
RUN echo "locales locales/default_environment_locale select fr_FR.UTF-8" | debconf-set-selections \
&& echo "locales locales/locales_to_be_generated multiselect 'fr_FR.UTF-8 UTF-8'" | debconf-set-selections
RUN echo "Europe/Paris" > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata

CMD apachectl -D FOREGROUND
