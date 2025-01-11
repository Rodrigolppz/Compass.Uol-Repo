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

Porém antes da migração acontecer para a nova estrutura, precisamos fazer uma
migração “lift-and-shift” ou “as-is”, o mais rápido possível, só depois que iremos
promover a modificação para a nova estrutura em Kubernetes.
