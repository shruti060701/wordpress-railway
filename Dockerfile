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

# Real, documented Railway-specific bug (confirmed via Railway's own community
# help station, multiple other WordPress deployers hit this exact error):
# this image's mpm_event/mpm_worker modules end up loaded alongside
# mpm_prefork in Railway's container runtime, and Apache refuses to start
# with more than one MPM active ("AH00534: More than one MPM loaded"). PHP's
# mod_php requires mpm_prefork specifically. Toggling modules at BUILD time
# alone (a2dismod/a2enmod as a plain RUN step) was tested and did NOT fix
# this - something in the runtime container re-enables the conflicting
# module after build. The confirmed-working fix (per Railway's own users
# hitting this exact bug) is to redo the module toggle in the START COMMAND,
# immediately before Apache actually launches.
RUN a2dismod mpm_event mpm_worker || true && a2enmod mpm_prefork

EXPOSE 80

CMD ["/bin/bash", "-c", "a2dismod mpm_event mpm_worker || true; a2enmod mpm_prefork; exec docker-entrypoint.sh apache2-foreground"]
