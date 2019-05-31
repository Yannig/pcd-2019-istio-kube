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

