FROM php:8.2-apache

# Enable Apache mod_rewrite if needed
RUN a2enmod rewrite

# Copy app files to Apache document root
COPY . /var/www/html/

# Optional: set permissions
RUN chown -R www-data:www-data /var/www/html

EXPOSE 80
