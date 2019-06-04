# pcd-2019-istio-kube

Repository d'exemple pour REX Istio et Kubernetes

![Archi cluster](/architecture.svg)

## Création cluster

La création se fait à l'aide de la commande eksctl récupérable à l'emplacement suivant : https://github.com/weaveworks/eksctl

Le fichier makefile contient le target de création suivant :

    make create-cluster

Ci-dessous la commande correspondante :

    eksctl create cluster --name=$CLUSTER_NAME --ssh-access \
      --node-volume-size=40 \
      --nodes=1 --nodes-max=5 --asg-access -t t2.xlarge \
      --external-dns-access -r $REGION \
      --kubeconfig ./kubeconfig/$CLUSTER_NAME.conf


## Init Helm

Helm (en version 2.x) est composé de deux parties : Le client Helm et le serveur Tiller.

L'initialisation de la partie Tiller se décompose en 3 opérations :
- Création d'un compte de service pour Tiller
- Attribution de droits admin
- Initialisation de Tiller


Ci-dessous le target :

    make tiller

## Installation controleur Ingress

    make nginx-ingress

## Installation external-dns

    make external-dns

## Installation gestionnaire de certificats

    make cert-manager

## Définition de l'émetteur de certificat par défaut

    make lets-encrypt-issuer

## Installation istio

    make istio-basic

Attendre le lancement des jobs dans l'espace de nom kube-sytem

    make istio-components

## Suppression cluster

    make create-cluster

## Accès

- Kiali : https://kiali.pcd-2019.aios.sh
- Mailhog via Ingress: https://mailhog-ingress.pcd-2019.aios.sh
- Mailhog via Istio Gateway : https://mailhog-istio.pcd-2019.aios.sh
- Application démo : https://demo-app.pcd-2019.aios.sh/productpage

## Activation sidecar

    k get ns -L istio-injection

    k label ns test-istio istio-injection=enabled

