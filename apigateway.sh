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
DEMO_PROMPT="${RED}[node 1] ${GREEN}(local) ${CYAN}root@192.168.0.18 ${PURPLE}\w ${WHITE}$ "

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
pe "docker ps"
pe "curl localhost:8001"

# KONGA
pe "docker run -p 1337:1337 --network kong-net --name konga  -e \"TOKEN_SECRET=chavesecreta\" -d pantsel/konga
pe "docker ps"

# Configurar KONGA

# Chamar as APIs
pe "curl -i -X POST --url http://localhost:8001/services/ --data 'name=exemplo' --data 'url=http://mockbin.org'"

#p "cat \"something you dont want to really run\""
# put your demo awesomeness here
#if [ ! -d "stuff" ]; then
#  pe "mkdir stuff"
#fi
# show a prompt so as not to reveal our true nature after
# the demo has concluded
p ""
