# Infraestrutura-Web-na-AWS-com-Monitoramento-Automatizado

Objetivo: Subir uma instância EC2 com Amazon Linux 2023, configurar um servidor web NGINX e um sistema de monitoramento em shell script que envia alertas via webhook para o Discord em caso de indisponibilidade do site.

Etapa 1: Configuração do Ambiente

1.1 Criação da VPC Personalizada:

Foi criada uma VPC customizada com as seguintes características:

CIDR block da VPC: 10.0.0.0/16
Internet Gateway: criado e associado à VPC.

Route Table pública:
Associação com as sub-redes públicas.
Rota 0.0.0.0/0 apontando para o Internet Gateway.

1.2 Sub-redes:
Foram criadas quatro sub-redes, com a seguinte separação:

 Tipo	      Nome	        CIDR Block	  
Pública	subnet-public-a	  10.0.1.0/24	                   
Pública	subnet-public-b	  10.0.2.0/24	                     
Privada	subnet-private-a	10.0.3.0/24	                    
Privada	subnet-private-b	10.0.4.0/24	     	                

Grupo de Segurança (Security Group)
Criado um Security Group com as seguintes regras:

1.3 Grupo de Segurança (Security Group)

Inbound:
Porta 22 (SSH): liberada apenas para seu IP local.
Porta 80 (HTTP): liberada para 0.0.0.0/0.

Etapa 2: Criação e Acesso à EC2

2.1 Instância

AMI utilizada: Amazon Linux 2023 (kernel 6.1)
Tipo de instância: t2.micro (elegível ao Free Tier)
Sub-rede usada: subnet-public-a
Par de chaves: vpc-public-key.pem

2.2 Acesso via SSH

Comando no terminal:

ssh -i ~/.ssh/vpc-public-key.pem ec2-user@<IP-PÚBLICO>
Substitua <IP-PÚBLICO> pelo IP da sua instância.

Etapa 3: Preparação da Instância

3.1 Atualização

sudo dnf update -y

3.2 Instalação de Nginx

sudo dnf install nginx -y
sudo systemctl enable nginx
sudo systemctl start nginx

3.3 Instalação do Cron

sudo dnf install cronie -y
sudo systemctl enable crond
sudo systemctl start crond

Etapa 4: Script de Monitoramento 

```bash
#!/bin/bash

URL="http://3.12.73.116"  
LOGFILE="/home/ale123/projeto.log"
WEBHOOK_URL="https://discord.com/api/webhooks/1397222745275629658/ZzvqCYSu2Wva4oquM73jPpup3LKiiS3HGziMbEi9XdNByDoMeV4ThnOj1GCOTJltr37I"

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
```

Permissões:
chmod +x /home/ale123/projeto.sh

Editar o cron:
crontab -e

Linha adicionada:
* * * * * /bin/bash /home/<USUARIO>/projeto.sh >> /home/<USUARIO>/projeto-cron.log 2>&1

Etapa 6: Teste

Simular site fora do ar:
sudo systemctl stop nginx

Verificar logs:
tail -n 10 /home/ale123/projeto.log

Subir o site novamente:
sudo systemctl start nginx
