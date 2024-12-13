#!/bin/bash

### Atualizar pacotes
sudo apt update -y
sudo apt upgrade -y

### Instalar o Docker
sudo apt install -y docker.io
sudo systemctl start docker
sudo groupadd docker || true
sudo usermod -aG docker ubuntu
sudo systemctl enable docker


### Instalar Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

### Configurar EFS
sudo apt-get install -y nfs-common
sudo mkdir -p /efs/teste
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport fs-01fb3b2270d3f4c1a.efs.us-east-1.amazonaws.com:/ /efs

### Criar arquivo docker-compose.yaml
cat <<EOF | sudo tee /home/ubuntu/docker-compose.yaml
services: 
  wordpress:
    image: wordpress
    ports:
      - "8080:80"
    restart: always
    environment:
      WORDPRESS_DB_HOST: database-project-compass.cjecaaw0kv3q.us-east-1.rds.amazonaws.com
      WORDPRESS_DB_USER: rodrigo
      WORDPRESS_DB_PASSWORD: 123456789
      WORDPRESS_DB_NAME: Project_Database
    volumes:
      - /efs:/var/www/html
EOF

### Iniciar containers com Docker Compose
cd /home/ubuntu
sudo docker-compose up -d

### Script

IP_EX2="UPDATE wp_options SET option_value = 'http://$(curl http://checkip.amazonaws.com):8080/' WHERE option_name = 'siteurl';"

sudo apt install mysql-client -y
host="database-project-compass.cjecaaw0kv3q.us-east-1.rds.amazonaws.com" && user="rodrigo" && pw="123456789"
mysql -h $host -u $user -p$pw Project_Database -e "$IP_EX2"
