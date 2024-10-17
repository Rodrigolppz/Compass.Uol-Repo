## Sprint 2 <img src="https://logospng.org/download/uol/logo-uol-icon-256.png" width="20"/> - Subir um Servidor NGINX e Criar um Script de Validação

<p>
  
  Desafio: Subir um servidor NGINX e criar um script que valide se o serviço está online ou offline, enviando o resultado da validação para um diretório específico a cada 5 minutos.

Contexto: Durante o desenvolvimento no WSL, enfrentei um obstáculo relacionado ao uso do comando systemctl, que não estava disponível, já que o sistema está utilizando o INIT em vez do systemd. Isso exigiu adaptações tanto no meu workflow quanto no script.

</p>


### Instalação do NGINX e criação do script:

- Instalar o Nginx → apt install nginx

- Conferir o status do Nginx → service nginx status (retorno esperado: nginx is running ou nginx is not running)

- Criar um diretório para armazenar os logs → mkdir /root/logs

- Criar o arquivo onde vai ficar o script → cd /root → nano nginx.sh

- Criar o script -> [Script](https://github.com/Rodrigolppz/Compass.Uol-Repo/blob/main/Sprint-2/nginx.sh)

 ### Explicação do script
 
 - Este script define três variáveis e cria uma estrutura condicional para verificar o status do serviço nginx. Caso o serviço esteja ativo, o script irá executar o bloco correspondente, exibindo na tela e registrando um log na pasta online com a mensagem indicando que o serviço está "ONLINE" e funcionando corretamente. Caso o serviço nginx esteja inativo, o script executa o outro bloco, exibindo a mensagem "OFFLINE" e registrando o status na pasta offline, indicando que o serviço não está ativo.


### Criar um crontab para cronometrar a cada 5 minutos o envio da validação:

- <strong>Pergunta</strong>: O que é um crontab e pra que serve ? 

- <strong>Resposta</strong>: O crontab é uma ferramenta usada para agendar tarefas que devem ser executadas automaticamente em horários específicos no sistema Linux. É extremamente útil quando você deseja automatizar tarefas como a execução de scripts, backups, ou, como neste caso, validar o status de um serviço a cada intervalo de tempo.

Comandos:

crontab -e (Vai abrir o editor do crontab)

 */5 * * * * /root/nginx.sh (Escrever esse comando na última linha)

Explicação:

*/5 significa que o script será executado a cada 5 minutos.
Os outros asteriscos * representam outras unidades de tempo (hora, dia do mês, mês, dia da semana). Como deixamos todos com asteriscos, o script será executado independentemente da hora, do dia ou do mês.
Essa linha garante que o script /root/nginx.sh seja executado automaticamente a cada 5 minutos, sem a necessidade de intervenção manual.
#


### Conclusão: 
Para conferir se está funcionando, basta digitar -> service nginx start -> tail -f /root/logs/status_online.log 

Se tudo estiver certo, aparecerá algo parecido com isso: 

![Descrição da imagem](https://github.com/Rodrigolppz/Compass.Uol-Repo/blob/main/Sprint-2/online.png)


Sinal de que está funcionando, com esse passo a passo o desafio foi concluído com sucesso! =)

