## Sprint 4 <img src="https://logospng.org/download/uol/logo-uol-icon-256.png" width="20"/> - Criar uma arquitetura na AWS e rodar um container com Wordpress.


## Desafio:
Criar uma arquitetura na AWS de acordo com essa imagem [Arquitetura AWS](https://github.com/Rodrigolppz/Compass.Uol-Repo/blob/main/Sprint-4/imagens/Projeto-Docker-AWS.jpg), o projeto consiste em fazer o deploy do wordpress dentro de um container e roda-lo numa EC2 com todas as configurações corretas. Certificando-se de que o container estará conectado com o RDS para que o wordpress funcione e que todas as configurações de redes estejam seguindo as boas práticas.

1. [Criação da VPC](#VPC)
2. [Criação do RDS](#RDS)
3. [Template EC2](#EC2)
4. [Security Groups](#SG)
5. [Auto Scaling Group](#ASG)



<div id='VPC'/> 
  
# 1. Criação da VPC

<p>
  Para começarmos o desafio, precisamos ter uma VPC criada corretamente, essa VPC será o ambiente principal que irá hospedar toda a aplicação e suas dependências de redes.

  Segue abaixo o esquema da VPC criada:
  
  ![Imagem](https://github.com/Rodrigolppz/Compass.Uol-Repo/blob/main/Sprint-4/imagens/VPC.jpg)

  O que é uma VPC ?
  
  Uma VPC (Virtual Private Cloud) é uma rede virtual isolada dentro da AWS, onde você pode definir e controlar os recursos de rede, como sub-redes, roteamento, gateways de internet e regras de firewall. Ela oferece um espaço onde você pode lançar recursos, como instâncias EC2, bancos de dados, e outros serviços de nuvem, em um ambiente seguro e isolado.
  
  
</p>

<div id='RDS'/>

# 2. Criação do RDS

Nesta etapa devemos criar o RDS, que é basicamente o banco de dados da AWS onde vai ficar os dados da nossa aplicação do Wordpress.

- Standard create
- Engine type: MySQL
- Engine version: latest
- Templates: free tier
- Instance configuration: db.t3.micro (2vCPUs 1GiB RAM)
- Storage: gp2 com 20GiB alocados
- Avaliability zone: No preference
- Database port: 3306 (Default do MySQL)



<div id='EC2'/>

# 3. Criação de um template EC2

Agora, vamos criar um template EC2, o qual facilita a criação de instâncias dentro de um Auto Scaling Group. Com esse template, não será necessário configurar as opções toda vez que precisarmos lançar uma nova instância.

- OS: Ubuntu

- Instance Type: t2.micro

- Key pair: my-ec2-key

- Security group: wordpress-sg

Mais pra frente falaremos sobre User_data.



<div id='SG'/>

# 4. Criação dos security groups

Os Security Groups funcionam como um firewall, controlando as permissões de entrada e saída para os serviços aos quais estão vinculados. Eles determinam quais conexões podem ser permitidas ou bloqueadas, garantindo maior segurança na comunicação.

Neste primeiro momento, criei dois Security Groups:

- Um para as instâncias EC2
- Outro para o RDS


<div id='ASG'/>

# 5. Criação do Auto Scaling Group

O Auto Scaling Group é um serviço da AWS que nos permite gerenciar de forma eficiente as instâncias em execução. Ele ajusta automaticamente a quantidade de instâncias, escalando para mais ou reduzindo sua capacidade, conforme a demanda.

Em `EC2 > Auto Scaling > Auto Scaling Groups > Create Auto Scaling group`

Segue as configurações do ASG:

- Name: AutoScaling-Project
- Launch Template: RodrigoEC2
- VPC: wordpress-vpc
- Avaliability Zones: 1a & 1b
- Subents: public 1a & public 1b

Para a parte `Configure group size and scaling` que é onde configuramos as capacidades de criar e derrubar instancias do Auto Scaling, optei pelas seguintes definições:


   - Desired capacity: 2
   - Min desired capacity: 2
   - Max desired capacity: 4
   - Automatic scaling:
       - Target tracking scaling policy
       - Metric type: Average CPU utilization
       - Target value: 40 (Assim que a média de utilização da CPU do grupo alcançar 40%, uma nova instancia será criada)
       - Instance warmup: 300 seconds
  - Instance maintenance policy: Mixed behavior / No policy

O Auto Scaling Group pode ser desativado temporariamente selecionando o mesmo na dashbord dos auto scaling groups, clicando em `Actions -> Edit` e mudando, na aba `Group Size`, os tres valores de `Desired capacity` para zero. Quando se deseja "despausar" o ASG basta fazer o mesmo processo e colocar os valores originais.


# 6. Criação do EFS - Elastic File System

Para armazenar os estáticos do container de aplicação Wordpress utilizei um Elastic File System (EFS) da AWS, que poderá ser acessado por todas as instancias EC2. Seu processo de configuração e montagem nas instancias será feito por meio do script de inicialização user_data.sh.

Mantive todas as opções default na criação deste recurso:

- Name: Projeto_Compass
- VPC: wordpress-vpc

Com o EFS criado basta agora fazermos a montagem dele na nossa máquina, para isso basta clicar em "Attach" dentro do EFS e colar o código que está abaixo de `Using the NFS client`, esse processo é feito no [User_Data](#USD).


<div id='USD'/>

# 7. Criação do User_Data

O user_data é uma configuração da EC2 que nos permite adicionar scripts para realizar algumas configurações de forma automática quando iniciamos uma nova máquina, sem ter que fazer tudo manualmente.

Vou separar esse tópico em algumas partes:

### 7.1 Docker

A primeira parte do script é sobre a instalação do docker.

```
#! /bin/bash

sudo apt install docker.io -y

sudo groupadd docker

sudo usermod -a -G docker ubuntu

docker pull wordpress
  ```


### 7.2 EFS

As linhas abaixo configuram o ambiente para permitir que a instância EC2 se conecte ao EFS (Elastic File System), um sistema de arquivos compartilhado e gerenciado pela AWS. Além disso, configuram a montagem do sistema de arquivos e garantem que ele seja persistido para uso contínuo, mesmo após reinicializações da máquina.

```
sudo apt-get -y install nfs-common

sudo mkdir /efs

sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport fs-01fb3b2270d3f4c1a.efs.us-east-1.amazonaws.com:/ /efs
```

### 7.3 Docker-Compose

Precisamos do docker-compose para rodar a aplicação do wordpress dentro do container e conecta-lo ao RDS.

```
sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

### 7.4 Criar e iniciar o arquivo docker-compose.yaml

Nessa parte eu estou criando o arquivo do docker-compose.yaml diretamente dentro da EC2 através do user_data

```
cat <<EOF | sudo tee /home/ubuntu/docker-compose.yaml
version: '3.8'
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

cd /home/ubuntu
sudo docker-compose up -d
```

### 7.5 Script 

Esse script automatiza a atualização do endereço do site no banco de dados do WordPress sempre que o IP da instância muda. Esse problema surgiu porque o WordPress estava persistindo o IP antigo na tabela wp_options, causando falhas na conexão após o restart ou troca da instância. A solução foi atualizar automaticamente o campo siteurl no banco de dados com o novo IP.

```
IP_EX2="UPDATE wp_options SET option_value = 'http://$(curl http://checkip.amazonaws.com):8080/' WHERE option_name = 'siteurl';"

sudo apt install mysql-client -y
host="database-project-compass.cjecaaw0kv3q.us-east-1.rds.amazonaws.com" && user="rodrigo" && pw="123456789"
mysql -h $host -u $user -p$pw Project_Database -e "$IP_EX2"
```

# 8 Load Balancer

Agora precisamos criar um Load Balancer para as subnets privadas 1a e 1b. Como essas subnets não têm acesso direto à internet, utilizarei um Bastion Host em uma subnet pública. O Bastion Host permitirá que eu acesse as instâncias nas subnets privadas de forma segura para realizar tarefas administrativas.
Além disso, para possibilitar que as instâncias privadas se comuniquem com a internet (por exemplo, para atualizações ou downloads), configurarei regras específicas de roteamento que utilizem o Bastion Host como intermediário, garantindo que essas subnets continuem inacessíveis diretamente pela internet, mantendo a segurança da infraestrutura.

### 8.1 Bastion Host

