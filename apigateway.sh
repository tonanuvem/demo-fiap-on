#!/usr/bin/env bash

########################
# include the magic
########################
. ./demo-magic.sh


########################
# Configure the options
########################

#
# speed at which to simulate typing. bigger num = faster
#
# TYPE_SPEED=20

#
# custom prompt
#
# see http://www.tldp.org/HOWTO/Bash-Prompt-HOWTO/bash-prompt-escape-sequences.html for escape sequences
#
DEMO_PROMPT="\r${RED}[node 1] ${GREEN}(local) ${CYAN}root@192.168.0.18 ${PURPLE}\w ${WHITE}$ "

# hide the evidence
clear

pe "docker pull nginx"
pe "docker pull postgres:9.6"
pe "docker pull kong"
pe "docker pull pantsel/konga"

pe "docker images"

# KONG

pe "docker network create kong-net"
pe "docker run -d --name kong-database --network=kong-net -p 5432:5432 -e \"POSTGRES_USER=kong\" -e \"POSTGRES_DB=kong\" postgres:9.6"
pe "docker ps"
pe "docker run --rm --network=kong-net -e \"KONG_DATABASE=postgres\" -e \"KONG_PG_HOST=kong-database\" kong:latest kong migrations bootstrap"
pe "docker run -d --name kong --network=kong-net -e \"KONG_DATABASE=postgres\" -e \"KONG_PG_HOST=kong-database\" -e \"KONG_PROXY_ACCESS_LOG=/dev/stdout\" -e \"KONG_ADMIN_ACCESS_LOG=/dev/stdout\" -e \"KONG_PROXY_ERROR_LOG=/dev/stderr\" -e \"KONG_ADMIN_ERROR_LOG=/dev/stderr\" -e \"KONG_ADMIN_LISTEN=0.0.0.0:8001, 0.0.0.0:8444 ssl\" -p 8000:8000 -p 8443:8443 -p 8001:8001 -p 8444:8444 kong:latest"
pe "docker ps"
pe "curl http://localhost:8001"
p ""

# KONGA
pe "docker run -p 1337:1337 --network kong-net --name konga  -e \"TOKEN_SECRET=chavesecreta\" -d pantsel/konga"
pe "docker ps"

# Configurar KONGA
p "cat \"vamos configurar o KONGA... rodando na porta 1337\""

# Chamar as APIs
pe "curl -i -X POST --url http://localhost:8001/services/ --data 'name=exemplo' --data 'url=http://mockbin.org'"
p ""
pe "curl -i -X POST --url http://localhost:8001/services/exemplo/routes --data 'hosts[]=mockbin.service'"
p ""
pe "curl -i -X POST --url http://localhost:8000/echo --header 'Host: mockbin.service' -d {\"chave\":\"valor\"}"
p ""
pe "curl -i -X POST --url http://localhost:8001/services/exemplo/plugins/ --data 'name=key-auth'"
p ""
pe "curl -i -X POST --url http://localhost:8000/delay/2000 --header 'Host: mockbin.service'"
p ""
pe "curl -i -X POST --url http://localhost:8001/consumers/ --data \"username=Aluno\""
p ""
pe "curl -i -X POST --url http://localhost:8001/consumers/Aluno/key-auth/ --data 'key=fiapsenha'"
p ""
pe "curl -i -X GET --url http://localhost:8000/delay/2000 --header 'Host: mockbin.service' --header \"apikey: fiapsenha\""





#p "cat \"something you dont want to really run\""
# put your demo awesomeness here
#if [ ! -d "stuff" ]; then
#  pe "mkdir stuff"
#fi
# show a prompt so as not to reveal our true nature after
# the demo has concluded
p ""
