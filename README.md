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

```bash
 Tipo	     Nome	          CIDR Block	  
Pública subnet-public-a	10.0.1.0/24	                   
Pública	subnet-public-b	10.0.2.0/24	                     
Privada	subnet-private-a10.0.3.0/24	                    
Privada	subnet-private-b10.0.4.0/24
```  	                

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

```bash
ssh -i ~/.ssh/vpc-public-key.pem ec2-user@<IP-PÚBLICO>
```
Substitua <IP-PÚBLICO> pelo IP da sua instância.

Etapa 3: Preparação da Instância

3.1 Atualização

```bash
sudo dnf update -y # Atualiza todos os pacotes do sistema.
```

3.2 Instalação de Nginx

```bash
sudo dnf install nginx -y # Instala o servidor web Nginx.
sudo systemctl enable nginx # Faz com que o Nginx inicie automaticamente com o sistema.
sudo systemctl start nginx #Inicia o serviço Nginx.
```

3.3 Instalação do Cron

```bash
sudo dnf install cronie -y #Instala o serviço de agendamento de tarefas
sudo systemctl enable crond #Ativa/inicia o daemon
sudo systemctl start crond #Executa as tarefas programadas 
```

Etapa 4: Script de Monitoramento 

```bash
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
```

Permissões:
```bash
chmod +x /home/<USUARIO>/projeto.sh
```

Editar o cron:
```bash
crontab -e # Abre o editor para editar tarefas agendadas do usuário.
```

Linha adicionada:
```bash
* * * * * /bin/bash /home/<USUARIO>/projeto.sh >> /home/<USUARIO>/projeto-cron.log 2>&1
```

Etapa 6: Teste

Simular site fora do ar:
```bash
sudo systemctl stop nginx # Para o servidor Nginx, simulando o site "fora do ar".
```

Verificar logs:
```bash
tail -n 10 /home/<USUARIO>/projeto.log
```

Subir o site novamente:
```bash
sudo systemctl start nginx
```
