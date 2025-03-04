#!/bin/bash

kubectl get coredb -n tembo-system --no-headers -o custom-columns=":metadata.name" | xargs kubectl delete coredb -n tembo-system

kubectl label namespace tembo-system tembo-pod-init.tembo.io/watch-

helm uninstall tembo -n tembo-system

kubectl get certificate -n tembo-system --no-headers -o custom-columns=":metadata.name" | xargs kubectl delete certificate -n tembo-system

kubectl get secret -n tembo-system --no-headers -o custom-columns=":metadata.name" | xargs kubectl delete secret -n tembo-system
