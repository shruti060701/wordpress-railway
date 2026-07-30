FROM wordpress:7.0.2-php8.3-apache

# Apache in the official image always listens on port 80 internally; this
# isn't reconfigurable via a simple env var the way some other apps are.
# Set PORT=80 explicitly as a Railway variable (see composer checklist) so
# Railway's edge routes to the right place - a lesson already learned the
# hard way on other templates in this collection (Metabase, Postiz,
# Vaultwarden, 9Router) where a Dockerfile-only port default wasn't enough.
RUN { \
    echo 'ServerName 0.0.0.0'; \
  } >> /etc/apache2/apache2.conf \
  && { \
    echo 'upload_max_filesize = 64M'; \
    echo 'post_max_size = 64M'; \
    echo 'memory_limit = 256M'; \
  } >> /usr/local/etc/php/conf.d/uploads.ini

EXPOSE 80
