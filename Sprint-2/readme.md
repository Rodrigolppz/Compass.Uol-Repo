# Documentação do Projeto de Monitoramento do Nginx

<p>Esta documentação descreve o processo que segui para configurar um script que monitora o status do servidor Nginx, registrando se ele está online ou offline em arquivos de log.</p>

<h2>Objetivo</h2>
<p>O objetivo deste projeto é criar um sistema que verifica periodicamente se o servidor Nginx está ativo e armazena os resultados em arquivos de log, permitindo que os administradores do sistema monitorem facilmente a disponibilidade do servidor.</p>

<h2>Passos Realizados</h2>

<h3>1. Instalação do Nginx</h3>
<p>Primeiramente, eu instalei o servidor Nginx no sistema. No terminal, executei:</p>
<pre><code>sudo apt update
sudo apt install nginx
</code></pre>

<h3>2. Verificação do Status do Nginx</h3>
<p>Após a instalação, eu verifiquei se o Nginx estava rodando corretamente:</p>
<pre><code>sudo systemctl status nginx
</code></pre>
<p>Essa etapa foi importante para garantir que o Nginx estivesse instalado e em execução antes de prosseguir.</p>

<h3>3. Criação do Diretório para os Logs</h3>
<p>Eu criei um diretório para armazenar os arquivos de log que o script geraria. Executei:</p>
<pre><code>mkdir -p /root/logs
</code></pre>

<h3>4. Criação do Script de Monitoramento</h3>
<p>Criei um script chamado <code>check_nginx.sh</code> que verificaria o status do Nginx e registraria os resultados. O conteúdo do script é o seguinte:</p>
<pre><code>#!/bin/bash

# Definindo variáveis
SERVICE="nginx"
LOG_DIR="/root/logs"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

# Verificando o status do serviço
if systemctl is-active --quiet "$SERVICE"; then
    STATUS="ONLINE"
    echo "$DATE - $SERVICE Status: $STATUS" >> "$LOG_DIR/status_online_nginx.log"
else
    STATUS="OFFLINE"
    echo "$DATE - $SERVICE Status: $STATUS" >> "$LOG_DIR/status_offline_nginx.log"
fi
</code></pre>

<h3>5. Permissões de Execução</h3>
<p>Depois de criar o script, eu dei permissões de execução para que ele pudesse ser executado:</p>
<pre><code>chmod +x /root/check_nginx.sh
</code></pre>

<h3>6. Agendamento do Script com Cron</h3>
<p>Para que o script fosse executado automaticamente a cada 5 minutos, eu editei o crontab:</p>
<pre><code>crontab -e
</code></pre>
<p>Adicionei a seguinte linha:</p>
<pre><code>*/5 * * * * /bin/bash /root/check_nginx.sh
</code></pre>

<h3>7. Testes e Validação</h3>
<p>Após a configuração, eu testei o script manualmente para garantir que estava funcionando como esperado:</p>
<pre><code>bash /root/check_nginx.sh
</code></pre>
<p>Verifiquei os arquivos de log em <code>/root/logs</code> para assegurar que as mensagens de status estavam sendo registradas corretamente.</p>

<h3>8. Verificação de Logs</h3>
<p>Para visualizar os resultados, usei os comandos:</p>
<pre><code>cat /root/logs/status_online_nginx.log
cat /root/logs/status_offline_nginx.log
</code></pre>

<h3>9. Resolução de Problemas</h3>
<p>Durante o processo, encontrei alguns problemas, como a falta de criação dos arquivos de log. Assegurei que o diretório <code>/root/logs</code> existisse e que o script tivesse permissão para gravar nesse diretório.</p>

<h2>Conclusão</h2>
<p>O sistema de monitoramento do Nginx foi implementado com sucesso. Agora, o status do servidor é verificado a cada 5 minutos, e os resultados são armazenados em arquivos de log, permitindo fácil acesso e monitoramento do estado do serviço.</p>
