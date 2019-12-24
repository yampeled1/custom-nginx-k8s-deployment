# Building the Image
docker build . --tag nginx_anyvision:v1.0

# applyin pv, pvc deployment service and ingress

kubectl apply -f pv.yml
kubectl apply -f pvc.yml
kubectl apply -f nginx-deplyment.yml
kubectl apply -f service.yml
kubectl apply -f ingress.yml