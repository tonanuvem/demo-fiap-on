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
DEMO_PROMPT="\r${RED}[\H] ${GREEN}(local) ${CYAN}root@192.168.0.18 ${PURPLE}\w ${WHITE}$ "

# hide the evidence
clear

# Microservice de Clientes

pe "git clone https://github.com/tonanuvem/clientes-microservice-mongodb.git""
pe "docker-compose up -d"
pe "docker ps"

# show a prompt so as not to reveal our true nature after
# the demo has concluded
p ""
