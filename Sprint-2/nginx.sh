SERVICE="nginx"
LOG_DIR="/root/logs/"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

mkdir -p "$LOG_DIR"

if service "$SERVICE" status; then
	STATUS="ONLINE"
	echo "$DATE - $SERVICE Status: $STATUS - O serviço está rodando perfeitamente!" >> "$LOG_DIR/status_online.log"
else
    STATUS="OFFLINE"
    echo "$DATE - $SERVICE Status: $STATUS - O serviço está parado!" >> "$LOG_DIR/status_offline.log"
fi
