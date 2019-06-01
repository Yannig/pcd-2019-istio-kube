# pcd-2019-istio-kube

Repository d'exemple pour REX Istio et Kubernetes


```mermaid
graph LR
  subgraph aws
    route53
    lb((lb))
    subgraph EKS
      subgraph system
        external-dns
        cert-manager
      end
      subgraph ingress
        nginx
      end
      subgraph istio
        gateway
        certificate
      end
    end
  end
  external-dns -.-> route53
  gateway -.-> external-dns
  nginx -.-> external-dns
  certificate -.-> cert-manager
  gateway -.-> certificate
  nginx -.-> cert-manager
  cert-manager -.-> letsencrypt
  lb -.-> gateway
  lb -.-> nginx
```

## Création cluster

    make create-cluster

## Init Helm

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

## Activation sidecar

    k get ns -L istio-injection

    k label ns test-istio istio-injection=enabled

