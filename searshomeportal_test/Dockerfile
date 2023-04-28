# Copyright 2020-2022 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Amazon Software License (the "License"). You may not use this file except in compliance with the License.
# A copy of the License is located at
#
#    http://aws.amazon.com/asl/
#
# or in the "license" file accompanying this file.
# This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, express or implied.
# See the License for the specific language governing permissions and limitations under the License.

FROM public.ecr.aws/amazonlinux/amazonlinux:2 AS core
#FROM amazonlinux:2

ARG INSTALL_PHP_VERSION="8.1"

# timezone
RUN set -ex \
    && unlink /etc/localtime \
    && ln -s -f /usr/share/zoneinfo/Japan /etc/localtime

# locale ja_JP.utf8
RUN set -ex \
    && yum install -y -q \
           glibc-langpack-ja
ENV LANG ja_JP.utf8
ENV LC_ALL ja_JP.utf8 

# Install SSH
RUN set -ex \
    && yum install -y -q openssh-server openssh-clients \
    && mkdir ~/.ssh \
    && touch ~/.ssh/known_hosts \
    && chmod 600 ~/.ssh/known_hosts \
    && echo 'root:srvrmt20230415' | chpasswd \
    && sed -ri 's/^#PermitRootLogin yes/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && ssh-keygen -t rsa -N "" -f /etc/ssh/ssh_host_rsa_key

# Install nginx
    #&& amazon-linux-extras enable corretto8 \
RUN set -ex \
    && amazon-linux-extras install epel -y \
    && yum install -y -q \
           nginx

# Install tools
RUN set -ex \
    && yum install -y -q \
           git unzip \
           msmtp mailx wget curl \
           procps-ng

# Install php
RUN set -ex \
    && amazon-linux-extras enable php${INSTALL_PHP_VERSION}

# check repository
#RUN set -ex \
#    && yum repolist all

# Install php
RUN set -ex \
    && yum install -y -q \
           php-fpm \
           php-mysqlnd \
           php-curl \
           php-xml \
           php-mbstring \
           php-bcmath \
           php-gd \
           php-opcache \
           php-soap \
           php

# update & clean all
RUN set -ex \
    && yum update -y -q \
    && yum clean all

#=======================End of layer: core  =================

# Configure NGINX
RUN set -ex \
    && rm /etc/nginx/nginx.conf \
    && rm -r /etc/nginx/default.d \
    && rm -r /etc/nginx/conf.d
COPY ./production/config/nginx/nginx.conf /etc/nginx/
COPY ./production/config/nginx/default.d /etc/nginx/default.d
COPY ./production/config/nginx/conf.d /etc/nginx/conf.d

# Configure NGINX
COPY ./production/config/php-fpm.d/www.conf /etc/php-fpm.d/www.conf

# Install composer
ENV COMPOSER_BINDIR /usr/local/bin
RUN set -ex \
    && wget -O composer-setup.php https://getcomposer.org/installer \
    && php composer-setup.php --install-dir=${COMPOSER_BINDIR} –filename=composer \
    && rm composer-setup.php \
    && mv ${COMPOSER_BINDIR}/composer.phar ${COMPOSER_BINDIR}/composer

# Install Contents(laravel source and more.) 
#COPY --chown=apache:apache --chmod=775 ./src /var/www/server
COPY ./src /var/www/server
WORKDIR /var/www/server
RUN set -ex \
    &&  composer install
RUN set -ex \
   && chown -R apache:apache /var/www/server \
   && chmod 775 /var/www/server \
   && find /var/www/server -type d -exec chmod 775 {} \; \
   && find /var/www/server -type f -exec chmod 664 {} \;

# Configure SSH
#COPY ssh_config /root/.ssh/config

#ENTRYPOINT ["/usr/local/bin/dockerd-entrypoint.sh"]
#CMD /usr/sbin/nginx -g "daemon off;"
COPY ./production/bin/startup.sh /usr/local/bin/startup.sh
RUN chmod 755 /usr/local/bin/startup.sh

CMD /usr/local/bin/startup.sh
#=======================End of layer: al2_v4  =================
