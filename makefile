ISTIO_VERSION="1.1.7"
ISTIO_BASIC_URL="pcd-2019.aios.sh"
ACTIVATE_TLS="true"
REGION="eu-west-3"
CLUSTER_NAME="pcd-2019"

tiller:
	kubectl create serviceaccount \
		--namespace kube-system tiller \
		--dry-run -o json | \
			jq 'del(.metadata.creationTimestamp)' |\
		kubectl apply -f -
	kubectl create clusterrolebinding tiller-cluster-rule \
		--clusterrole=cluster-admin \
		--serviceaccount=kube-system:tiller \
		--dry-run -o json | \
			jq 'del(.metadata.creationTimestamp)' |\
		kubectl apply -f -
	helm init --service-account tiller --wait

uninstall-tiller:
	helm reset | cat
	kubectl delete clusterrolebinding tiller-cluster-rule --ignore-not-found
	kubectl delete -n kube-system serviceaccount tiller --ignore-not-found

istio-repo:
	helm repo add istio.io https://storage.googleapis.com/istio-release/releases/$(ISTIO_VERSION)/charts

istio-init:
	helm upgrade --install istio-init istio.io/istio-init --namespace istio-system --wait

istio-basic: istio-repo istio-init

istio-components:
	cat istio/chart/*.yaml |\
	sed "s/ISTIO_BASIC_URL/$(ISTIO_BASIC_URL)/g" |\
	sed "s/ACTIVATE_TLS/$(ACTIVATE_TLS)/" |\
	helm upgrade --install istio istio.io/istio \
		--namespace istio-system \
		-f -

create-cluster:
	eksctl create cluster --name=$(CLUSTER_NAME) --ssh-access \
		--node-volume-size=40 \
		--nodes=1 --nodes-max=5 --asg-access -t t2.xlarge \
		--external-dns-access -r $(REGION) \
		--kubeconfig ./kubeconfig/$(CLUSTER_NAME).conf

destroy-cluster:
	eksctl delete cluster --name=$(CLUSTER_NAME) -r $(REGION)

.PHONY: external-dns
external-dns:
	helm upgrade --install external-dns stable/external-dns \
		--namespace kube-system -f external-dns/chart.yaml --set aws.region=$(REGION)

nginx-ingress:
	helm upgrade --install nginx-ingress stable/nginx-ingress \
		--namespace nginx-ingress --set rbac.create=true \
		--set controller.publishService.enabled=true

# Ne fonctionne pas directement avec Helm actuellement en version 1.12 de Kube
.PHONY: cert-manager
cert-manager:
	kubectl apply \
		-f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.8/deploy/manifests/00-crds.yaml
	kubectl label namespace kube-system certmanager.k8s.io/disable-validation="true" --overwrite
	helm repo add jetstack https://charts.jetstack.io
	# Download chart in cache directory
	helm inspect jetstack/cert-manager > /dev/null
	# Install chart without validation
	helm template ~/.helm/cache/archive/cert-manager-v0.8.0.tgz --name cert-manager \
		--namespace=kube-system -f cert-manager/chart.yaml | kubectl apply -f - --validate=false

cert-manager-alternative:
	kubectl get ns cert-manager || kubectl create namespace cert-manager
	kubectl label namespace cert-manager certmanager.k8s.io/disable-validation=true --overwrite
	kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v0.8.0/cert-manager.yaml --validate=false
