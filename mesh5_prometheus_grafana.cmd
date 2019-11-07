kubectl -n istio-system port-forward svc/prometheus 9090:9090
kubectl -n istio-system port-forward svc/grafana 3000:3000
kubectl apply -f samples/bookinfo/telemetry/metrics.yaml
kubectl apply -f samples/bookinfo/telemetry/tcp-metrics.yaml
:: Acessar 20 vezes a aplicação para gerar as métricas: 
curl http:/192.168.99.100:31380/productpage?[1-20]
start "" http://localhost:3000
