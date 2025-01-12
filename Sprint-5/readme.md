## Sprint 5 <img src="https://logospng.org/download/uol/logo-uol-icon-256.png" width="20"/> - Migrando Servidor On-premise para EKS

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



