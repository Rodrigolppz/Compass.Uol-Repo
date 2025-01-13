## Sprint 5 <img src="https://logospng.org/download/uol/logo-uol-icon-256.png" width="20"/> - Migrando Servidor On-premise para EKS

### 👥 Dupla:

- Rodrigo Ascenção
- Rodigo Raynton

## Cenário 

"Nós somos da empresa "Fast Engineering S/A" e gostaríamos de uma solução dos senhores(as), que fazem parte da empresa terceira "TI SOLUÇÕES INCRÍVEIS". Nosso eCommerce está crescendo e a solução atual não está atendendo mais a alta demanda de acessos e compras que estamos tendo. Desde o início do ano os acessos e compras estão crescendo 20% a cada mês." 

![.](https://github.com/Rodrigolppz/Compass.Uol-Repo/blob/main/Sprint-5/On-premise.jpg)

#

## Desafio:

Migrar esse servidor on-premise para a AWS, a nova arquitetura deve seguir as seguintes diretrizes:

• Ambiente Kubernetes;
  
• Banco de dados gerenciado (PaaS e Multi AZ);

• Backup de dados;

• Sistema para persistência de objetos (imagens, vídeos etc.);

• Segurança;

Antes da migração acontecer para a nova estrutura, precisamos fazer uma
migração “lift-and-shift” ou “as-is”, o mais rápido possível, só depois que iremos
promover a modificação para a nova estrutura em Kubernetes.

#

## 1º Etapa - Realizar a migração lift-and-shift

![.](https://github.com/Rodrigolppz/Compass.Uol-Repo/blob/main/Sprint-5/Migra%C3%A7%C3%A3o.jpg)

Esta imagem representa a migração lift-and-shift, que consiste em transferir o ambiente anteriormente físico para a nuvem, sem realizar nenhuma alteração na arquitetura ou configuração original.

### Como funciona ? 

### 1 - MGN

#### O que é ?

MGN é a abreviação para <b>AWS Application Migration Service</b>, um serviço da AWS utilizado para realizar a migração lift-and-shift de servidores on-premises para a nuvem, sem a necessidade de modificar aplicações, sistema operacional ou configuração.

#### Como o MGN faz isso ? 

O MGN funciona instalando um agente de replicação nas máquinas de origem que você deseja migrar. Esse agente coleta dados continuamente e os replica para volumes no Amazon Elastic Block Store (EBS), vinculados a instâncias EC2 na AWS. A comunicação ocorre de forma segura por meio da porta 1500, que é usada para transferência de dados. Isso permite a sincronização contínua até que você esteja pronto para iniciar as instâncias migradas.


### 2 - DMS 

#### O que é ? 

DMS é a abreviação de <b>AWS Database Migration Service</b>, um serviço gerenciado da AWS que permite migrar bancos de dados rapidamente e com segurança para a nuvem, mantendo o banco de dados de origem totalmente operacional durante a migração. Ele suporta migração de diversos tipos de bancos de dados, como relacionais, NoSQL e data warehouses.

#### Como o DMS faz isso ? 

O DMS funciona ao criar uma instância de replicação que conecta o banco de dados de origem e o banco de dados de destino. Ele utiliza endpoints para definir as conexões e é capaz de realizar migrações em três modos principais: Migração de carga completa,  Replicação contínua, Transformação de dados opcional.

### 3 - Fluxo de migração

Agora que entendemos o que é o MGN e o DMS e como cada um funciona, vamos à explicação da arquitetura: 

Primeiro precisamos fazer a migração do banco de dados antes de realizar as dos servidores, pois assim quando migrarmos os servidores os endpoints já estarão associados ao RDS ( banco de dados da AWS).
Utilizaremos o <b>DMS</b> para realizar essa migração, associando um source point e um target point. 

Para realizar a migração do front-end e back-end, iremos utilizar o MGN para instalar o agente em ambos os servidores. O agente será responsável por coletar todos os dados de cada servidor e transferi-los através da porta 1500 para as EC2 na AWS, utilizando o direct connect, tendo em vista que não temos um IP fixo associado às instâncias. 

Essas transferências serão feitas para a <b>Stagging area</b>, que é uma área provisória para testes após a migração, quando tudo estiver pronto e funcionando, iremos  transferir tudo mais uma vez para a área <b>Migrated resources</b>, que é onde nossa arquitetura ficará de fato.

#

# Serviços e Recursos usados na Arquitetura As-is

- <b>Amazon CloudFront</b>: 
  É um serviço de entrega de conteúdo usado para distribuir conteúdo estático, como imagens e arquivos, de forma eficiente e rápida.
    *Desafio*: Alto crescimento de acessos e compras. 
    *Solução*: Distribuição global, eficiente e veloz de conteúdo estático
  
- <b>Amazon Route 53</b>:
  Serviço DNS para registro e gerenciamento de domínios, com roteamento de tráfego para recursos AWS (ELB, CloudFront).
    *Desafio*: Disponibilidade e resiliência insuficientes. 
    *Solução*: Roteamento de tráfego eficiente e alta disponibilidade, direcionando acessos para instâncias e serviços AWS.

 - <b>AWS WAF</b>:
  O AWS Web Application Firewall é um serviço de firewall que ajuda a proteger aplicações web contra ataques comuns.
    *Desafio*: Proteger o eCommerce.
    *Solução*: Proteção avançada contra ameaças, garantindo a segurança da aplicação web.

- <b>VPC</b>:
  A Virtual Private Cloud isolará a infraestrutura na nuvem e fornecerá controle granular sobre a rede, com a criação de uma rede privada virtual, melhorará a segurança e o isolamento.
    *Desafio*: Isolamento e segurança de rede.
    *Solução*: Criação de uma rede VPC, trazendo controle de tráfego e segurança aprimorados.

- <b>NAT GATEWAY</b>:
  O NAT Gateway permite que instâncias em sub-redes privadas na AWS acessem a internet ou outros serviços externos sem expor seus IPs privados diretamente. Ele atua como um intermediário, traduzindo os endereços IP privados para públicos durante o tráfego de saída. Isso melhora a segurança e evita a necessidade de atribuir IPs públicos às instâncias privadas.

- <b>Amazon RDS</b>:
  O Relational Database Service será usado para hospedar o banco de dados MySQL, garantindo alta disponibilidade, escalabilidade e backup automático dos dados.
    *Desafio*: Desempenho e escalabilidade insuficientes do banco de dados. 
    *Solução*: BD gerenciado com alta disponibilidade, escalabilidade e backup automático.

- <b>Load Balancer</b>:
 O Load Balancer distribui automaticamente o tráfego de rede ou de aplicação entre várias instâncias para otimizar o desempenho e aumentar a disponibilidade. Ele monitora a saúde dos recursos e redireciona o tráfego para instâncias saudáveis. Essa estratégia melhora a escalabilidade e evita sobrecargas em um único servidor.

- <b>Elastic Block Store</b>:
O EBS é um serviço de armazenamento de blocos da AWS usado com instâncias EC2. Ele oferece volumes persistentes para dados, permitindo armazenar arquivos, bancos de dados e aplicações. Os volumes EBS são altamente escaláveis e podem ser configurados para desempenho otimizado ou tolerância a falhas.

- <b>Direct connect</b>:  O AWS Direct Connect é um serviço que estabelece uma conexão privada dedicada entre a rede local de uma empresa e a AWS. Ele oferece maior largura de banda, menor latência e mais segurança em comparação com conexões padrão de internet. Isso facilita a transferência de grandes volumes de dados com estabilidade e desempenho aprimorado.

#

# Modernização da Arquitetura
Nesta etapa é onde faremos a modernização da arquitetura. Uma vez que o servidor on-premise já foi migrado, basta atendermos a próxima solicitação do cliente.


 
