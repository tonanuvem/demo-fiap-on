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
# DEMO_PROMPT="\r${RED}[\H] ${GREEN}(local) ${CYAN}root@192.168.0.18 ${PURPLE}\w ${WHITE}$ "
DEMO_PROMPT="\r${WHITE}ubuntu@OSBOXES:\w $ "

# hide the evidence
clear

# pe "git config --global user.name \"aluno\""
# pe "git config --global user.email \"email@fiap.com.br\""

pe "git init"
pe "git add *"
pe "git commit -m \"criando repo\""

pe "git remote add origin https://github.com/usuario/novo-repo.git"

pe "git push -f origin master"

pe "docker run -d --name kong --network=kong-net -e \"KONG_DATABASE=postgres\" -e \"KONG_PG_HOST=kong-database\" -e \"KONG_PROXY_ACCESS_LOG=/dev/stdout\" -e \"KONG_ADMIN_ACCESS_LOG=/dev/stdout\" -e \"KONG_PROXY_ERROR_LOG=/dev/stderr\" -e \"KONG_ADMIN_ERROR_LOG=/dev/stderr\" -e \"KONG_ADMIN_LISTEN=0.0.0.0:8001, 0.0.0.0:8444 ssl\" -p 8000:8000 -p 8443:8443 -p 8001:8001 -p 8444:8444 kong:latest"
p ""
