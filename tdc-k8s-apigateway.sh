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
REGION=us-central1
ZONE=${REGION}-b
PROJECT=$(gcloud config get-value project)
CLUSTER=gke-fiap

# Criar um cluster de dois nós:
gcloud container clusters create ${CLUSTER} --num-nodes=2 --zone ${ZONE} --cluster-version=latest

# Istio cluster com pelo menos 4 nós para fornecer recursos suficientes:
#gcloud beta container clusters create $CLUSTER \
#    --addons=Istio --istio-config=auth=MTLS_STRICT \
#    --cluster-version=latest \
#    --machine-type=n1-standard-2 \
#    --num-nodes=4 --zone $ZONE
#kubectl label namespace NAMESPACE istio-injection=enabled
#kubectl get service -n istio-system#

# Verificar as 2 instâncias e os pods do namespace kube-system:
gcloud container clusters get-credentials $CLUSTER --zone $ZONE
kubectl get pods -n kube-system
gcloud compute instances list

# Rodar microservicos no Kubernetes
git clone https://github.com/tonanuvem/k8s-slackpage.git
cd k8s-slackpage
git clone https://github.com/tonanuvem/k8s-slackpage.git
cd k8s-slackpage
kubectl create -f svc_fiap_gcp.yml
kubectl get svc

# Executar a aplicação Sock Shop : A Microservice Demo Application
kubectl create -f demo-weaveworks-socks.yaml
kubectl get svc -n sock-shop
kubectl get all -n sock-shop

# Executar a aplicação HTTPBIN
kubectl apply -f https://bit.ly/k8s-httpbin

# Executar a aplicação ECHO
kubectl apply -f https://bit.ly/echo-service

# https://github.com/Kong/kubernetes-ingress-controller/blob/master/docs/guides/using-kongplugin-resource.md

# Setup Ingress rules
# Let's expose these services outside the Kubernetes cluster by defining Ingress rules.
echo '
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: demo
  annotations:
    konghq.com/strip-path: "true"
spec:
  rules:
  - http:
      paths:
      - path: /foo
        backend:
          serviceName: httpbin
          servicePort: 80
      - path: /bar
        backend:
          serviceName: echo
          servicePort: 80
' | kubectl apply -f -

# Let's test these endpoints:
curl -i $PROXY_IP/foo/status/200
curl -i $PROXY_IP/bar

# https://github.com/Kong/kubernetes-ingress-controller/blob/master/docs/guides/using-consumer-credential-resource.md
# Let's add a KongPlugin resource for authentication on the httpbin service:
echo "apiVersion: configuration.konghq.com/v1
kind: KongPlugin
metadata:
  name: httpbin-auth
plugin: key-auth
" | kubectl apply -f -
kubectl patch service httpbin -p '{"metadata":{"annotations":{"konghq.com/plugins":"httpbin-auth"}}}'

# Let's test these endpoints: agora o httpbin deve receber HTTP/1.1 401 Unauthorized
curl -i $PROXY_IP/foo/status/200
curl -i $PROXY_IP/bar

# Let's create a KongConsumer resource:
$ echo "apiVersion: configuration.konghq.com/v1
kind: KongConsumer
metadata:
  name: harry
username: harry" | kubectl apply -f -

# Provision an API-key associated with this consumer so that we can pass the authentication
kubectl create secret generic harry-apikey  \
  --from-literal=kongCredType=key-auth  \
  --from-literal=key=my-sooper-secret-key
  
# Associate this API-key with the consumer we created previously.
echo "apiVersion: configuration.konghq.com/v1
kind: KongConsumer
metadata:
  name: harry
username: harry
credentials:
- harry-apikey" | kubectl apply -f -

# Use the API key to pass authentication:
curl -I $PROXY_IP/foo -H 'apikey: my-sooper-secret-key'

# ---------

# pe "docker pull nginx"
pe "docker pull postgres:9.6"
pe "docker pull kong"
pe "docker pull pantsel/konga"

pe "docker images"

# KONG

pe "kubectl apply -f https://bit.ly/kong-ingress-dbless"
pe "kubectl get svc -n kong"
export PROXY_IP=$(kubectl get service/servicename -o jsonpath='{.spec.clusterIP}')
export PROXY_IP=$(kubectl get svc <your-service> -o yaml | grep ip)
pe "curl -i $PROXY_IP"
p ""

# KONGA
pe "docker run -p 1337:1337 --network kong-net --name konga  -e \"TOKEN_SECRET=chavesecreta\" -d pantsel/konga"
pe "docker ps"

# Configurar KONGA
p "#vamos configurar o KONGA... rodando na porta 1337"

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
