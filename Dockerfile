FROM ubuntu:14.04

MAINTAINER im@Mxp.tw

ENV  DEBIAN_FRONTEND=noninteractive


RUN  apt-get update
RUN  apt-get upgrade -y

# PreInstall
RUN  mkdir -p /var/log/supervisor
RUN apt-get install nano wget git vim openssh-server supervisor -y
# Nginx
RUN  wget -O - http://nginx.org/keys/nginx_signing.key | sudo apt-key add -
RUN  echo "deb http://nginx.org/packages/mainline/ubuntu/ trusty nginx" >> /etc/apt/sources.list
RUN  echo "deb-src http://nginx.org/packages/mainline/ubuntu/ trusty nginx" >> /etc/apt/sources.list
RUN  mkdir -p /usr/share/nginx/www
RUN  apt-get update && apt-get install nginx -y
# PHP
RUN  apt-get install software-properties-common python-software-properties  -y
RUN  locale-gen en_US.UTF-8
ENV  LANG=en_US.UTF-8
ENV  LANG=C.UTF-8
RUN  LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php
RUN  apt-get update
RUN  mkdir -p /var/run/php
RUN  apt-get install php5.6-fpm -y
RUN  apt-get install php5.6-xml php5.6-gd php5.6-mysql php5.6-cli php5.6-curl php5.6-mbstring -y
# Upgrade
RUN  apt-get upgrade -y
# Setup SSH
RUN echo 'root:root' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN echo 'PasswordAuthentication no' >> /etc/ssh/sshd_config
RUN mkdir /var/run/sshd && chmod 0755 /var/run/sshd
RUN mkdir -p /root/.ssh/
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
ADD server.key.pub  /root/.ssh/authorized_keys
# drush
#RUN wget http://files.drush.org/drush.phar
#RUN php drush.phar core-status
#RUN chmod +x drush.phar
#RUN sudo mv drush.phar /usr/local/bin/drush
#RUN drush init -y
# mysql
RUN apt-get update \
    && apt-get install mysql-client -y
    #&& apt-get install -y debconf-utils \
    #&& echo mysql-server mysql-server/root_password password  YOURPASSWORD | debconf-set-selections \
    #&& echo mysql-server mysql-server/root_password_again password YOURPASSWORD | debconf-set-selections \
    #&& apt-get install -y mysql-server

VOLUME ["/usr/share/nginx/www", "/etc/php/5.6/fpm"]
EXPOSE 80 22

# Settings
RUN  apt-get clean -y && apt-get autoclean -y && apt-get autoremove -y
ADD  default.conf /etc/nginx/conf.d/default.conf
ADD  nginx.conf /etc/nginx/
ADD  supervisord.conf /etc/supervisor/conf.d/supervisord.conf

CMD ["/usr/bin/supervisord"]
