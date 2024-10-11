Sprint 2 - Subir um Servidor NGINX e Criar um Script de Validação

Desafio: Subir um servidor NGINX e criar um script que valide se o serviço está online ou offline, enviando o resultado da validação para um diretório específico a cada 5 minutos.

Contexto: Durante o desenvolvimento no WSL, enfrentei um obstáculo relacionado ao uso do comando systemctl, que não estava disponível, já que o sistema está utilizando o INIT em vez do systemd. Isso exigiu adaptações tanto no meu workflow quanto no script.

Abaixo vou detalhar o passo a passo de como concluí esse desafio:

Passos para conclusão:

Instalar o Nginx → apt install nginx

Conferir o status do Nginx → service nginx status (retorno esperado: nginx is running ou nginx is not running)

Criar um diretório para armazenar os logs → mkdir /root/logs

4 - criar o arquivo onde vai ficar o script → cd /root → nano nginx.sh

5 - Hora de fazer o script de fato:

[Clique aqui para ser direcionado à pasta com o script](https://github.com/Rodrigolppz/Compass.Uol-Repo/blob/main/Sprint-2/nginx.sh)

6 - Realizar a segunda condição, criando um crontab para cronometrar a cada 5 minutos o envio da validação:

crontab -e 
Adicionar o seguinte comando na última linha -> */5 * * * * /root/nginx.sh

Cada asterístico representa uma unidade de medida, a primeira representa os minutos..

