cd "C:\Users\logonrmlocal\Downloads\istio-1.3.0"
kubectl apply -f install/kubernetes/helm/helm-service-account.yaml
helm init --service-account tiller
helm install install/kubernetes/helm/istio-init --name istio-init --namespace istio-system
helm list
kubectl get crds | grep 'istio.io' | wc -l
