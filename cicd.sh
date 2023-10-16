#!/bin/bash

#파라미터 개수 체크
if [ $# -eq 1 ]; then
  APPLY=${1}
fi

REPOSITORY="pda-project"
APP="client-app"
NAMESPACE="kdb"

DATETIME=`date '+%Y%m%d%H%M%S'`
TAG=${DATETIME}

IMAGE=${REPOSITORY}:${TAG}
DOCKERPATH=./Dockerfile

AWS_PROFILE=default
AWS_REGION=ap-northeast-2

export AWS_DEFAULT_PROFILE=${AWS_PROFILE}
export AWS_DEFAULT_REGION=${AWS_REGION}
env | grep AWS

CLUSTER=shinhan-pda-cluster
rm -rf ./dist/*

# ==================
echo "aws eks login .."
# ==================
aws eks --region ${AWS_REGION} update-kubeconfig --name ${CLUSTER} --profile ${AWS_PROFILE}

# ==================
echo "aws ecr login .."
# ==================
env | grep AWS
aws ecr get-login-password --region  ${AWS_REGION} | docker login --username AWS --password-stdin 686710509719.dkr.ecr.ap-northeast-2.amazonaws.com

# ==================
echo "docker build .."
# ==================
sudo docker build --platform=linux/amd64 -t ${IMAGE} .

# ==================
echo "docker tagging .."
# ==================
docker tag ${IMAGE} 686710509719.dkr.ecr.ap-northeast-2.amazonaws.com/${IMAGE}

# ==================
echo "docker push .."
# ==================
docker push 686710509719.dkr.ecr.ap-northeast-2.amazonaws.com/${IMAGE}

if [ "$APPLY" == "deploy" ]; then
	echo "----------${IMAGE}----------"
	kubectl config set-context $(kubectl config current-context) --namespace=${NAMESPACE}
	kubectl set image deployment/${APP} ${APP}=686710509719.dkr.ecr.ap-northeast-2.amazonaws.com/${IMAGE} --namespace=${NAMESPACE}
	kubectl --namespace ${NAMESPACE} rollout status deployment.v1.apps/${APP}
	kubectl get pod,svc,hpa,ingress -o wide --namespace=${NAMESPACE}
	echo "------------------------------"
fi
