cd istio-1.3.0
kubectl apply -f samples/bookinfo/networking/destination-rule-all.yaml
start /b kubectl -n istio-system port-forward svc/kiali 20001:20001
start /min chrome http://admin:admin@127.0.0.1:20001
cd ..
