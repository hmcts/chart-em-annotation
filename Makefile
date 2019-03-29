.DEFAULT_GOAL := all
CHART := em-annotation
CI_VALUES := ci-values.yaml
RELEASE := chart-${CHART}-release
NAMESPACE := chart-tests
TEST := ${RELEASE}-test-service
ACR := hmctssandbox
AKS_RESOURCE_GROUP := cnp-aks-sandbox-rg
AKS_CLUSTER := cnp-aks-sandbox-cluster
SUBSCRIPTION := bf308a5c-0624-4334-8ff8-8dca9fd43783

setup:
	az configure --defaults acr=${ACR}
	az acr helm repo add -n hmcts
	az aks get-credentials --resource-group ${AKS_RESOURCE_GROUP} --name ${AKS_CLUSTER} --overwrite-existing --subscription ${SUBSCRIPTION}
	helm dependency update ${CHART}

delete:
	-helm delete --purge ${RELEASE}

clean:
	-helm delete --purge ${RELEASE}
	-kubectl delete pod ${TEST} -n ${NAMESPACE}

lint:
	helm lint ${CHART} --namespace ${NAMESPACE} -f ci-values.yaml

inspect:
	helm inspect chart ${CHART}

deploy:
	helm install ${CHART} --name ${RELEASE} --namespace ${NAMESPACE} -f ${CI_VALUES}  --wait  --timeout 400

test:
	helm test ${RELEASE}

all: setup clean lint deploy test

.PHONY: setup clean lint deploy test all
