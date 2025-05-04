# Use multi-stage to support both PHP and HTML builds
ARG APP_TYPE=html
ARG APP_DIR

FROM php:8.2-apache AS php-base
COPY ${APP_DIR}/ /var/www/html/
LABEL app=${APP_DIR}

FROM nginx:alpine AS html-base
COPY ${APP_DIR}/ /usr/share/nginx/html/
LABEL app=${APP_DIR}

# Final stage: select the correct base
FROM ${APP_TYPE}-base
