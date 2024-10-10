#!/bin/bash

# Definindo variáveis
SERVICE="nginx"
LOG_DIR="/root/logs/"  # Diretório para armazenar os logs
DATE=$(date '+%Y-%m-%d %H:%M:%S')

# Criar o diretório de logs, se não existir
mkdir -p "$LOG_DIR"

# Verificar se o Nginx está ativo
if systemctl is-active --quiet "$SERVICE"; then
    STATUS="ONLINE"
    echo "$DATE - $SERVICE Status: $STATUS - O serviço está rodando perfeitamente!" >> "$LOG_DIR/status_online.log"
else
    STATUS="OFFLINE"
    echo "$DATE - $SERVICE Status: $STATUS - O serviço está parado!" >> "$LOG_DIR/status_offline.log"
fi

