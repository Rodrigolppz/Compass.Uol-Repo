Sprint 2 - Subir um servidor NGINX e Criar um script que valide se está online e envie o resultado da validação para um diretório específico.

Condições: O projeto deve ser realizado utilizando Ubuntu pelo WSL e o resultado da validação deve ser enviado a cada 5 minutos.

Complicação que surgiu: pelo WSL eu não estava conseguindo usar o comando Systemctl, foi ai que descobri que estava usando o sistema INIT, portanto isso gerou alguams novas adaptações tanto no meu workflow quanto no script.

Abaixo vou detalhar o passo a passo de como concluí esse desafio:

1 - Instalar o Nginx → apt install nginx

2 - conferir o status do nginx → service nginx status ( nginx is running ou nginx is not running)

3 - criar um diretório para mostrar os logs de saída, se o serviço está online ou offline → mkdir /root/logs

4 - criar o arquivo onde vai ficar o script → cd /root → nano nginx.sh

5 - Hora de fazer o script de fato:

[Clique aqui para ser direcionado à pasta com o script]

6 - Realizar a segunda condição, criando um crontab para cronometrar a cada 5 minutos o envio da validação:

crontab -e 
Adicionar o seguinte comando na última linha -> */5 * * * * /root/nginx.sh

Cada asterístico representa uma unidade de medida, a primeira representa os minutos..

