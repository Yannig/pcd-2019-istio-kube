# pcd-2019-istio-kube

Repository d'exemple pour REX Istio et Kubernetes

## Création cluster

    make create-cluster

## Init Helm

    make tiller

## Installation controleur Ingress

    make nginx-ingress

## Installation external-dns

    make external-dns

## Installation istio

    make istio-basic

Attendre le lancement des jobs dans l'espace de nom kube-sytem

    make istio-components

## Suppression cluster

    make create-cluster
