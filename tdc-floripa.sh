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
DEMO_PROMPT="\r${WHITE}andre@cloudshell:${CYAN}~ ${YELLOW}(onyx-principle-267820)\w ${WHITE}$ "

# hide the evidence
clear

#	Definir as variáveis de ambiente:
pe "REGION=us-central1"
p ""
pe "ZONE=${REGION}-b"
p ""
pe "PROJECT=$(gcloud config get-value project)"
p ""
pe "CLUSTER=gke-tdc-floripa"

# Criar um cluster de dois nós:
p ""
pe "gcloud container clusters create ${CLUSTER} --num-nodes=3 --zone ${ZONE} --cluster-version=latest"

# Verificar as 2 instâncias e os pods do namespace kube-system:
p ""
pe "gcloud container clusters get-credentials $CLUSTER --zone $ZONE"
p ""
pe "kubectl get pods -n kube-system"
p ""
pe "gcloud compute instances list"

# Rodar microservicos no Kubernetes
p "cat 'vamos Executar a aplicação FIAP (slackpage):'"
p ""
pe "git clone https://github.com/tonanuvem/k8s-slackpage.git"
p ""
pe "kubectl create -f k8s-slackpage/deploy_fiap.yml"
p ""
pe "kubectl create -f k8s-slackpage/svc_fiap_gcp.yml"
p ""
pe "kubectl get svc"

# Executar a aplicação Sock Shop : A Microservice Demo Application
p "cat 'vamos Executar a aplicação Sock Shop (Microservice Demo Application):'"
p ""
pe "kubectl create -f k8s-slackpage/demo-weaveworks-socks.yaml"
p ""
pe "kubectl get svc -n sock-shop"
#kubectl get all -n sock-shop


# HELM
p "cat 'vamos configurar o HELM:'"
pe "helm version"
# Verificar versão do Client e do Server (v2 ou v3)
#
p ""
pe "curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3"
p ""
pe "chmod 700 get_helm.sh"
p ""
pe "./get_helm.sh"
#
p ""
pe "helm version"
# Verificar versão do Client e do Server (v2 ou v3)

##
# KONG
p "cat 'vamos configurar o KONG:'"
pe "helm repo add bitnami https://charts.bitnami.com/bitnami"
# helm search repo bitnami
p ""
pe "helm repo update"
p ""
pe "kubectl create ns kong"
p ""
pe "helm install kong --set service.exposeAdmin=true --set service.type=LoadBalancer --namespace kong bitnami/kong"
p ""
pe "kubectl get svc -n kong"
p ""
pe "export SERVICE_IP=$(kubectl get svc --namespace kong kong -o jsonpath='{.status.loadBalancer.ingress[0].ip}')"
p ""
pe "echo http://$SERVICE_IP"
p ""
pe "curl http://$SERVICE_IP"
## mensagem acima vai indicar que ainda não há rotas configuradas
## se nao pegou o IP Externo, confirmar:
# kubectl edit svc kong -n kong
# verificar type: LoadBalancer

##
# KONGA
p "cat 'vamos configurar o KONGA:'"
pe "git clone https://github.com/pantsel/konga.git"
p ""
pe "cd konga/charts/konga/"
p ""
pe "helm install konga -f ./values.yaml ../konga --set service.type=LoadBalancer --namespace kong --wait"
p ""
pe "kubectl get svc konga -n kong"
## se nao pegou o IP Externo, confirmar:
# kubectl edit svc konga -n kong
# verificar type: LoadBalancer
## Criar usuario admin, Logar e Clicar em Dashboard
# Preencher os seguintes campos na configuração:
#		Name 			= kong
#		Kong Admin URL 	= http://kong:8001

# https://www.digitalocean.com/community/tutorials/uma-introducao-ao-servico-de-dns-do-kubernetes-pt
# Chamar as APIs para configurar ROTAS
pe "echo $SERVICE_IP"
p ""
pe "curl -i -X POST --url http://$SERVICE_IP:8001/services/ --data 'name=exemplo' --data 'url=http://mockbin.org'"
p ""
pe "curl -i -X POST --url http://$SERVICE_IP:8001/services/exemplo/routes --data 'paths[]=/mockbin'"
p ""
pe "curl -i -X GET --url http://$SERVICE_IP/mockbin/echo -d {"chave":"valor"}"
p ""
pe "curl -i -X POST --url http://$SERVICE_IP:8001/services/ --data 'name=fiap' --data 'url=http://fiap-service.default.svc.cluster.local'"
p ""
pe "curl -i -X POST --url http://$SERVICE_IP:8001/services/fiap/routes --data 'paths[]=/fiap'"
p ""
pe "curl -i -X GET --url http://$SERVICE_IP/fiap"
p ""
pe "curl -i -X POST --url http://$SERVICE_IP:8001/services/ --data 'name=loja' --data 'url=http://front-end.sock-shop.svc.cluster.local'"
p ""
pe "curl -i -X POST --url http://$SERVICE_IP:8001/services/loja/routes --data 'paths[]=/'"
p ""
pe "curl -i -X POST --url http://$SERVICE_IP:8001/services/loja/routes --data 'paths[]=/loja'"
p ""
pe "curl -i -X GET --url http://$SERVICE_IP/loja"
p ""
pe "curl -i -X POST --url http://$SERVICE_IP:8001/services/exemplo/plugins/ --data 'name=key-auth'"
p ""
pe "curl -i -X POST --url http://$SERVICE_IP/mockbin/delay/2000"
p ""
pe "curl -i -X POST --url http://$SERVICE_IP:8001/consumers/ --data \"username=TDC\""
p ""
pe "curl -i -X POST --url http://$SERVICE_IP:8001/consumers/TDC/key-auth/ --data 'key=senha'"
p ""
pe "curl -i -X GET --url http://$SERVICE_IP/mockbin/delay/2000 --header \"apikey: senha\""


#p "cat \"something you dont want to really run\""
# put your demo awesomeness here
#if [ ! -d "stuff" ]; then
#  pe "mkdir stuff"
#fi
# show a prompt so as not to reveal our true nature after
# the demo has concluded
p ""



########### Excluir o cluster do GKE

gcloud container clusters delete $CLUSTER --zone $ZONE


# ---------
