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
CLUSTER=gke-tdc-floripa

# Criar um cluster de dois nós:
gcloud container clusters create ${CLUSTER} --num-nodes=3 --zone ${ZONE} --cluster-version=latest

# Verificar as 2 instâncias e os pods do namespace kube-system:
gcloud container clusters get-credentials $CLUSTER --zone $ZONE
kubectl get pods -n kube-system
gcloud compute instances list

# Rodar microservicos no Kubernetes
git clone https://github.com/tonanuvem/k8s-slackpage.git
kubectl create -f k8s-slackpage/deploy_fiap.yml
kubectl create -f k8s-slackpage/svc_fiap_gcp.yml
kubectl get svc

# Executar a aplicação Sock Shop : A Microservice Demo Application
kubectl create -f k8s-slackpage/demo-weaveworks-socks.yaml
kubectl get svc -n sock-shop
#kubectl get all -n sock-shop


# HELM
# helm version
# Verificar versão do Client e do Server (v2 ou v3)
#
# curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
# chmod 700 get_helm.sh
# ./get_helm.sh
#
# helm version
# Verificar versão do Client e do Server (v2 ou v3)
#
#
# KONG
# helm repo add bitnami https://charts.bitnami.com/bitnami
# helm search repo bitnami
# helm repo update
# kubectl create ns kong
# helm install kong --set service.exposeAdmin=true --set service.type=LoadBalancer --namespace kong bitnami/kong
# kubectl get svc -n kong
# export SERVICE_IP=$(kubectl get svc --namespace kong kong -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
# echo http://$SERVICE_IP:80
# curl http://$SERVICE_IP:80
## mensagem acima vai indicar que ainda não há rotas configuradas
## se nao pegou o IP Externo, confirmar:
# kubectl edit svc kong -n kong
# verificar type: LoadBalancer
# 
## Informações extras de exemplos:
#  Access the Kong proxy by using the following commands
#    echo "Browse to http://127.0.0.1:8000"
#    kubectl port-forward svc/my-release-kong 8080:80 &
#  Access the Kong admin by using the following commands
#    echo "Browse to http://127.0.0.1:8001"
#    kubectl port-forward svc/my-release-kong 8001:8001 &
#     The Kong Ingress Controller was deployed as part of the Kong pods. The following objects are available in the Kubernetes API:
#     kubectl get kongconsumers
#     kubectl get kongcredentials
#  name: my-release-kong
#     kubectl get kongingresses
#     kubectl get kongplugins
# If you want to upgrade the installation you will need to re-set the database credentials. Execute the following command
#  kubectl get secret --namespace default my-release-postgresql -o jsonpath="{.data.postgresql-password}" | base64 --decode
#
# KONGA
# git clone https://github.com/pantsel/konga.git
# cd konga/charts/konga/
# helm install konga -f ./values.yaml ../konga --namespace kong --wait
## ou
# helm install konga -f ./values.yaml ../konga --set service.type=LoadBalancer --namespace kong --wait
# kubectl get svc konga -n kong
## se nao pegou o IP Externo, confirmar:
# kubectl edit svc konga -n kong
# verificar type: LoadBalancer
## Criar usuario admin, Logar e Clicar em Dashboard
# Preencher os seguintes campos na configuração:
#		Name 			= kong
#		Kong Admin URL 	= http://kong:8001
## Informações extras:
# export POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/name=konga,app.kubernetes.io/instance=konga" -o jsonpath="{.items[0].metadata.name}")
# echo "Visit http://127.0.0.1:8080 to use your application"
# kubectl port-forward $POD_NAME 8080:80


# pe "docker pull nginx"
pe "docker pull postgres:9.6"
pe "docker pull kong"
pe "docker pull pantsel/konga"

pe "docker images"


# KONGA
pe "docker run -p 1337:1337 --network kong-net --name konga  -e \"TOKEN_SECRET=chavesecreta\" -d pantsel/konga"
pe "docker ps"

# Configurar KONGA
p "#vamos configurar o KONGA... rodando na porta 1337"

# https://www.digitalocean.com/community/tutorials/uma-introducao-ao-servico-de-dns-do-kubernetes-pt
# Chamar as APIs
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




########## KONG Extra (sem usar Helm)

# Istio cluster com pelo menos 4 nós para fornecer recursos suficientes:
#gcloud beta container clusters create $CLUSTER \
#    --addons=Istio --istio-config=auth=MTLS_STRICT \
#    --cluster-version=latest \
#    --machine-type=n1-standard-2 \
#    --num-nodes=4 --zone $ZONE
#kubectl label namespace NAMESPACE istio-injection=enabled
#kubectl get service -n istio-system#

# KONG

pe "kubectl apply -f https://bit.ly/kong-ingress-dbless"
pe "kubectl get svc -n kong"
export PROXY_IP=$(kubectl get service/servicename -o jsonpath='{.spec.clusterIP}')
export PROXY_IP=$(kubectl get svc <your-service> -o yaml | grep ip)
kubectl get -o jsonpath="{.status.loadBalancer.ingress[0].ip}" service -n kong kong-proxy
pe "curl -i $PROXY_IP"
p ""

kubectl apply -f https://bit.ly/kong-ingress-dbless
kubectl get svc -n kong
#export PROXY_IP=$(kubectl get service/servicename -o jsonpath='{.spec.clusterIP}')
#export PROXY_IP=$(kubectl get svc <your-service> -o yaml | grep ip)
export PROXY_IP=$(kubectl get -o jsonpath="{.status.loadBalancer.ingress[0].ip}" service -n kong kong-proxy)
echo $PROXY_IP
pe "curl -i $PROXY_IP"
p ""
# Executar a aplicação HTTPBIN
kubectl apply -f https://bit.ly/k8s-httpbin

# Executar a aplicação ECHO
kubectl apply -f https://bit.ly/echo-service

### https://github.com/Kong/kubernetes-ingress-controller/blob/master/docs/guides/using-kongplugin-resource.md

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
      - path: /httpbin
        backend:
          serviceName: httpbin
          servicePort: 80
      - path: /echo
        backend:
          serviceName: echo
          servicePort: 80
      - path: /fiap
        backend:
          serviceName: fiap-service
          servicePort: 80
' | kubectl apply -f -

# https://discuss.konghq.com/t/how-to-use-kongingress-to-redirect-to-different-backend-path/3848
echo '
apiVersion: configuration.konghq.com/v1
kind: KongIngress
metadata:
  name: kongingress-loja
  namespace: sock-shop
proxy:
  path: /loja
route:
  strip_path: true
' | kubectl apply -f -

echo '
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: ingress-loja
  namespace: sock-shop
  annotations:
    konghq.com/strip-path: "true"
    configuration.konghq.com: kongingress-loja
spec:
  rules:
  - http:
      paths:
      - path: /
        backend:
          serviceName: front-end
          servicePort: 80
      - path: /loja
        backend:
          serviceName: front-end
          servicePort: 80
' | kubectl apply -f -

# kubectl patch -n sock-shop service front-end -p '{"metadata":{"annotations":{"configuration.konghq.com":"kongingress-loja"}}}'

# Let's test these endpoints:
curl -i $PROXY_IP/httpbin/status/200
curl -i $PROXY_IP/echo

### https://github.com/Kong/kubernetes-ingress-controller/blob/master/docs/guides/using-consumer-credential-resource.md
# Let's add a KongPlugin resource for authentication on the httpbin service:
echo "apiVersion: configuration.konghq.com/v1
kind: KongPlugin
metadata:
  name: httpbin-auth
plugin: key-auth
" | kubectl apply -f -
kubectl patch service httpbin -p '{"metadata":{"annotations":{"konghq.com/plugins":"httpbin-auth"}}}'

# Let's test these endpoints: agora o httpbin deve receber HTTP/1.1 401 Unauthorized
curl -i $PROXY_IP/httpbin/status/200
curl -i $PROXY_IP/echo

# Let's create a KongConsumer resource:
echo "apiVersion: configuration.konghq.com/v1
kind: KongConsumer
metadata:
  name: usuario
username: usuario" | kubectl apply -f -

# Provision an API-key associated with this consumer so that we can pass the authentication
kubectl create secret generic usuario-apikey  \
  --from-literal=kongCredType=key-auth  \
  --from-literal=key=senha
  
# Associate this API-key with the consumer we created previously.
echo "apiVersion: configuration.konghq.com/v1
kind: KongConsumer
metadata:
  name: usuario
username: usuario
credentials:
- usuario-apikey" | kubectl apply -f -

# Use the API key to pass authentication:
curl -I $PROXY_IP/httpbin -H 'apikey: senha'


### https://github.com/Kong/kubernetes-ingress-controller/blob/master/docs/guides/using-external-service.md
### Expose an external application

# Create a Kubernetes service
echo "
kind: Service
apiVersion: v1
metadata:
  name: svc-externo
spec:
  ports:
  - protocol: TCP
    port: 80
  type: ExternalName
  externalName: mockbin.org
" | kubectl create -f -

# Create an Ingress to expose the service at the path /foo
echo '
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: ingress-externo
  annotations:
    konghq.com/strip-path: "true"
    konghq.com/preserve-host: "false"
spec:
  rules:
  - http:
      paths:
      - path: /externo
        backend:
          serviceName: svc-externo
          servicePort: 80
' | kubectl create -f -

# Test the service
curl -i $PROXY_IP/externo


### https://github.com/Kong/kubernetes-ingress-controller/blob/master/docs/guides/configure-acl-plugin.md
### Add JWT authentication to the service
echo "
apiVersion: configuration.konghq.com/v1
kind: KongPlugin
metadata:
  name: app-jwt
plugin: jwt
" | kubectl apply -f -

# Let's associate the plugin to the Ingress rules we created earlier.
echo '
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: demo-jwt
  annotations:
    plugins.konghq.com: app-jwt
    konghq.com/strip-path: "false"
spec:
  rules:
  - http:
      paths:
      - path: /echo
        backend:
          serviceName: echo
          servicePort: 80
' | kubectl apply -f -

# Now it will require a valid JWT and the consumer for the JWT to be associate with the right ACL. HTTP/1.1 401 Unauthorized
curl -i $PROXY_IP/echo

# Informações Extras:

# blue green e canary:
# https://docs.konghq.com/2.0.x/loadbalancing/

# ---------
