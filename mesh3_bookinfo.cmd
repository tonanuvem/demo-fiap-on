kubectl label namespace default istio-injection=enabled 
kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml
kubectl apply -f samples/bookinfo/networking/bookinfo-gateway.yaml
kubectl get gateway
start "" http:/192.168.99.100:31380/productpage
