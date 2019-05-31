ISTIO_VERSION="1.1.7"
ISTIO_BASIC_URL="pcd-2019.aios.sh"
ACTIVATE_TLS="true"

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
