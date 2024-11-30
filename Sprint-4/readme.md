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

