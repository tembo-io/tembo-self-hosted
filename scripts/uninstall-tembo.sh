#!/bin/bash

kubectl get coredb -n tembo --no-headers -o custom-columns=":metadata.name" | xargs kubectl delete coredb -n tembo

kubectl label namespace tembo tembo-pod-init.tembo.io/watch-

helm uninstall tembo -n tembo

kubectl get certificate -n tembo --no-headers -o custom-columns=":metadata.name" | xargs kubectl delete certificate -n tembo

kubectl get secret -n tembo --no-headers -o custom-columns=":metadata.name" | xargs kubectl delete secret -n tembo
