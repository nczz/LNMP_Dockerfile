### Install Docker

apt-get update && apt-get upgrade -y && apt-get install curl -y
curl -fsSL https://get.docker.com/ | sh

### Install MySQL with Docker

docker run --name mysql-5-7 -v /home/mysql-5-7/conf:/etc/mysql/conf.d -v /home/mysql-5-7/db:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=my-secret-pw -d mysql:5.7

### Build LNP Server

ssh-keygen -b 4096 -f server.key
docker build -t lnp_server .

### MySQL Linked with Nginx+PHP

docker run -d --restart=always --name server_name --link mysql-5-7 -p 80:80 -v /home/site/www:/usr/share/nginx/www -v /home/site/php_conf:/etc/php/5.6/fpm -v /home/site/nginx_conf:/etc/nginx lnp_server