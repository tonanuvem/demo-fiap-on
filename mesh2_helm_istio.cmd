cd istio-1.3.0
kubectl get crds | grep 'istio.io' | wc -l
@ECHO Verificar se o numero acima = 23
helm install install/kubernetes/helm/istio --name istio --namespace istio-system --values install/kubernetes/helm/istio/values-istio-demo.yaml --set gateways.istio-ingressgateway.type=NodePort
cd ..
start /b minikube dashboard
