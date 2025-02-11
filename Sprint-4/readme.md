## Sprint 4 <img src="https://logospng.org/download/uol/logo-uol-icon-256.png" width="20"/> - Criar uma arquitetura na AWS e rodar um container com Wordpress.


## Desafio:
Criar uma arquitetura na AWS de acordo com essa imagem [Arquitetura AWS](https://github.com/Rodrigolppz/Compass.Uol-Repo/blob/main/Sprint-4/imagens/Projeto-Docker-AWS.jpg), o projeto consiste em fazer o deploy do wordpress dentro de um container e roda-lo numa EC2 com todas as configurações corretas. Certificando-se de que o container estará conectado com o RDS para que o wordpress funcione e que todas as configurações de redes estejam seguindo as boas práticas.

1. [Criação da VPC](#VPC)
2. [Criação do RDS](#RDS)
3. [Template EC2](#EC2)
4. [Security Groups](#SG)
5. [Auto Scaling Group](#ASG)
6. [EFS](#6)
7. [User_Data](#USD)
8. [Load Balancer e Target group](#8)
9. [NAT Gateway](#9)


   





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

Neste primeiro momento, criei os security groups:

- ec2-wordpress-private -> para as instancias privadas
- 
- RDS_SecurityGroup -> somente para o RDS
- 
- EFS-SG -> somente para o EFS
- 
- LoadBalancer -> somente para o LoadBalancer


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

<div id='#6'/>

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
      WORDPRESS_DB_HOST: ...
      WORDPRESS_DB_USER: ...
      WORDPRESS_DB_PASSWORD: ...
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
IP_EX2="UPDATE wp_options SET option_value = 'http://ProjectAPP-2006900803.us-east-1.elb.amazonaws.com:8080' WHERE option_name = 'siteurl';"

sudo apt install mysql-client -y
host="..." && user="..." && pw="..."
mysql -h $host -u $user -p$pw Project_Database -e "$IP_EX2"
```

<div id='8'/> 
  
# 8 Load Balancer

Por questões de conflito com o Classical Load balancer, eu optei por seguir o projeto utilizando Application Load Balancer, segue abaixo a configuração:

- Scheme: internet-facing (para permitir acessos externos).
  
- VPC: A VPC onde as instâncias EC2 e o ALB estão localizados. (wordpress-vpc)
  
- Subnets: Aqui selecionei subnets públicas para o ALB (isso permite que o tráfego externo alcance o ALB).
  
- Listeners: Configurei o listener para a porta 80 com o protocolo HTTP, que encaminha as requisições para as instâncias EC2 no Target Group.
  
- Target Group: O Target Group foi configurado com o protocolo HTTP e a porta 8080, pois a aplicação está rodando na porta 8080 dentro do container.


### 8.2 Target Group

Configuração do Target Group:

- Criei um Target Group para as instâncias EC2.
  
- Configurei o Target Group para usar o protocolo HTTP na porta 8080.
  
- Verifiquei que as instâncias EC2 estavam saudáveis no Target Group.

### 8.3 Bastion Host

Para que eu consiga acessar dentro das instâncias privadas, precisei configurar um Bastion host, que nada mais é do que uma instância pública que servirá como ponte para acessarmos a instância privada.

![.](https://github.com/Rodrigolppz/Compass.Uol-Repo/blob/main/Sprint-4/imagens/Bastian%20host%20EC2.jpg)

<div id='9'/> 

# 9 NAT Gateway

Para que a EC2 privada tenha acesso externo para realizar as instalações necessárias, precisamos configurar um NAT Gateway em uma subnet pública e associa-lo a uma rota privada, fazendo assim com que as instâncias que estejam em determinada subnet privada, consigam ter acesso à internet através do NAT Gateway

|Destination      |Target               
|----------------|-----------------------
|0.0.0.0/0       |NAT Gateway                   
|ID              |nat-091be10202be2d614                   


![Nat](https://github.com/Rodrigolppz/Compass.Uol-Repo/blob/main/Sprint-4/imagens/NAT.jpg)

# 10 CloudWatch

Utilizaremos a ferramenta da AWS chamada <b>CloudWatch</b> para monitorar a nossa EC2

### 10.1 Passo a passo

Vá até a instância que deseja monitorar `botão direito em cima dela -> Monitor and Trouleshoot -> Manage CloudWatch Alarms`

![M](https://github.com/Rodrigolppz/Compass.Uol-Repo/blob/main/Sprint-4/imagens/Manage%20%20CloudWatch.jpg)

### 10.2 Configuração: 

Alarm configuration: ProjectAlarm

Alarm thresholds

Average: Cpu Utilizations

Alarm when >= 50

O restante fica como default.

### 10.3 Simple Notification Service

Na aba de Simple Notification Service, defini que o alarme fosse enviado para o meu e-mail quando as especificações fossem atingidas.

Para realizar o teste, utilizei o comando `stress --cpu 9` dentro da instância configurada.

Após alguns minutos de estresse, recebi o seguinte aviso no e-mail:

![Email](https://github.com/Rodrigolppz/Compass.Uol-Repo/blob/main/Sprint-4/imagens/Email%20Alarm.jpg)

