helm install install/kubernetes/helm/istio --name istio --namespace istio-system --values install/kubernetes/helm/istio/values-istio-demo.yaml --set gateways.istio-ingressgateway.type=NodePort
minikube dashboard
