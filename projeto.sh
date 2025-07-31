#!/bin/bash

URL="http://<URL>"  
LOGFILE="/home/<USUARIO>/projeto.log"
WEBHOOK_URL="https://discord.com/api/webhooks/SEU_WEBHOOK_AQUI"

DATA=$(date '+%Y-%m-%d %H:%M:%S')

# Fazer requisição HTTP e pegar status HTTP
STATUS=$(curl -o /dev/null -s -w "%{http_code}" "$URL")

if [ "$STATUS" -eq 200 ]; then
    echo "$DATA - Site OK (HTTP $STATUS)" >> "$LOGFILE"
else
    echo "$DATA - ERRO! Site indisponível (HTTP $STATUS)" >> "$LOGFILE"

    # Enviar notificação para Discord via webhook
    curl -H "Content-Type: application/json" -X POST -d "{\"content\": \"ALERTA: Site $URL está indisponível! HTTP status: $STATUS em $DATA\"}" "$WEBHOOK_URL"
fi
