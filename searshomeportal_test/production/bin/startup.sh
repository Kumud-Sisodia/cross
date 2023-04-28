#!/usr/bin/env bash
#
#service ssh start
/usr/sbin/sshd
#
#service php7.3-fpm start
/usr/sbin/php-fpm -D
#
##service nginx start
/usr/sbin/nginx -g "daemon off;"
