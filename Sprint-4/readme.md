## Sprint 4 <img src="https://logospng.org/download/uol/logo-uol-icon-256.png" width="20"/> - Criar uma arquitetura na AWS e rodar um container com Wordpress.


## Desafio:
Criar uma arquitetura na AWS de acordo com essa [imagem](https://github.com/Rodrigolppz/Compass.Uol-Repo/blob/main/Sprint-4/imagens/Projeto-Docker-AWS.jpg)

1. [Criação da VPC](#VPC)



# 1. Criação da VPC

<p>
  Para começarmos o desafio, precisamos ter uma VPC criada corretamente, essa VPC será o ambiente principal que irá hospedar toda a aplicação e suas dependências de redes.

  Segue abaixo o esquema da VPC criada:
  
  ![Imagem](https://github.com/Rodrigolppz/Compass.Uol-Repo/blob/main/Sprint-4/imagens/VPC.jpg)

  O que é uma VPC ?
  
  Uma VPC (Virtual Private Cloud) é uma rede virtual isolada dentro da AWS, onde você pode definir e controlar os recursos de rede, como sub-redes, roteamento, gateways de internet e regras de firewall. Ela oferece um espaço onde você pode lançar recursos, como instâncias EC2, bancos de dados, e outros serviços de nuvem, em um ambiente seguro e isolado.
  
  
</p>


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



# 3. Criação de um template EC2

Agora, vamos criar um template EC2, o qual facilita a criação de instâncias dentro de um Auto Scaling Group. Com esse template, não será necessário configurar as opções toda vez que precisarmos lançar uma nova instância.

- OS: Ubuntu

- Instance Type: t2.micro

- Key pair: my-ec2-key

- Security group: wordpress-sg

Mais pra frente falaremos sobre User_data.


# 4. Criação dos security groups

Os Security Groups funcionam como um firewall, controlando as permissões de entrada e saída para os serviços aos quais estão vinculados. Eles determinam quais conexões podem ser permitidas ou bloqueadas, garantindo maior segurança na comunicação.

Neste primeiro momento, criei dois Security Groups:

- Um para as instâncias EC2
- Outro para o RDS

# 5. Criação do Auto Scaling Group

O Auto Scaling Group é um serviço da AWS que nos permite gerenciar de forma eficiente as instâncias em execução. Ele ajusta automaticamente a quantidade de instâncias, escalando para mais ou reduzindo sua capacidade, conforme a demanda.
