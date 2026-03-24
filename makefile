AWS_PROFILE ?= fiapaws
AWS_REGION ?= us-east-1
TFSTATE_BUCKET ?= toggle-master-tfstate
ACCOUNT_ID ?= 903947067217
IMAGE_TAG ?= local
CLUSTER_ENDPOINT ?= 
API_KEY ?= tm_key_8f4c1b9d2e7a6c5f0d3a1e9b7c4f2a8d6e1c3b5a7f9d2c4e6b8a0d1f3c5e7a9
API_KEY_MASTER ?= tm_master_4b7d9f2c6a1e8d3f5b0c7a9e2d4f6c1b8a3e5d7f9c2a4b6


terraform_backend_bootstrap:
	AWS_PROFILE=$(AWS_PROFILE) terraform -chdir=terraform/bootstrap/tf-backend init
	AWS_PROFILE=$(AWS_PROFILE) terraform -chdir=terraform/bootstrap/tf-backend apply --auto-approve -var="aws_region=$(AWS_REGION)" -var="bucket_name=$(TFSTATE_BUCKET)"

terraform_apply:
	AWS_PROFILE=$(AWS_PROFILE) terraform -chdir=terraform/main plan -var-file=terraform.tfvars
	AWS_PROFILE=$(AWS_PROFILE) terraform -chdir=terraform/main apply --auto-approve -var-file=terraform.tfvars
	sleep 10
	aws eks update-kubeconfig --region $(AWS_REGION) --profile $(AWS_PROFILE) --name togglemaster_project-cluster

terraform_destroy:
	AWS_PROFILE=$(AWS_PROFILE) terraform -chdir=terraform/main apply --auto-approve -var-file=terraform.tfvars -var="enable_argocd=false"
	for ns in auth-service flag-service targeting-service evaluation-service analytics-service; do \
		kubectl -n "$$ns" delete deploy,svc,ingress,hpa,job,configmap --all --ignore-not-found=true; \
	done
	AWS_PROFILE=$(AWS_PROFILE) terraform -chdir=terraform/main destroy --auto-approve -var-file=terraform.tfvars -var="enable_argocd=false"

docker_build:
	@if [ -z "$(ACCOUNT_ID)" ]; then echo "Defina ACCOUNT_ID, ex.: make docker_build ACCOUNT_ID=123456789012"; exit 1; fi
	aws ecr get-login-password --region $(AWS_REGION) --profile $(AWS_PROFILE) | docker login --username AWS --password-stdin $(ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com
	cd apps/local/1-auth-service && docker build -t $(ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/togglemaster_auth-service:$(IMAGE_TAG) . && docker push $(ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/togglemaster_auth-service:$(IMAGE_TAG)
	cd apps/local/2-flag-service && docker build -t $(ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/togglemaster_flag-service:$(IMAGE_TAG) . && docker push $(ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/togglemaster_flag-service:$(IMAGE_TAG)
	cd apps/local/3-targeting-service && docker build -t $(ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/togglemaster_targeting-service:$(IMAGE_TAG) . && docker push $(ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/togglemaster_targeting-service:$(IMAGE_TAG)
	cd apps/local/4-evaluation-service && docker build -t $(ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/togglemaster_evaluation-service:$(IMAGE_TAG) . && docker push $(ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/togglemaster_evaluation-service:$(IMAGE_TAG)
	cd apps/local/5-analytics-service && docker build -t $(ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/togglemaster_analytics-service:$(IMAGE_TAG) . && docker push $(ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/togglemaster_analytics-service:$(IMAGE_TAG)

init_2.1:
	@if [ -z "$(CLUSTER_ENDPOINT)" ]; then echo "Defina CLUSTER_ENDPOINT, ex.: make init_2.1 CLUSTER_ENDPOINT=meu-lb.us-east-1.elb.amazonaws.com API_KEY_MASTER=..."; exit 1; fi
	@if [ -z "$(API_KEY_MASTER)" ]; then echo "Defina API_KEY_MASTER."; exit 1; fi
	curl -X POST http://$(CLUSTER_ENDPOINT)/auth-service/admin/keys -H "Content-Type: application/json" -H "Authorization: Bearer $(API_KEY_MASTER)" -d '{"name": "admin-para-flag-service"}'

init_2.2:
	@if [ -z "$(CLUSTER_ENDPOINT)" ]; then echo "Defina CLUSTER_ENDPOINT."; exit 1; fi
	@if [ -z "$(API_KEY)" ]; then echo "Defina API_KEY."; exit 1; fi
	curl -X POST http://$(CLUSTER_ENDPOINT)/flag-service/flags -H "Content-Type: application/json" -H "Authorization: Bearer $(API_KEY)" -d '{"name": "enable-new-dashboard","description": "Ativa o novo dashboard para usuários","is_enabled": true}'

init_2.3:
	@if [ -z "$(CLUSTER_ENDPOINT)" ]; then echo "Defina CLUSTER_ENDPOINT."; exit 1; fi
	@if [ -z "$(API_KEY)" ]; then echo "Defina API_KEY."; exit 1; fi
	curl -X POST http://$(CLUSTER_ENDPOINT)/targeting-service/rules -H "Content-Type: application/json" -H "Authorization: Bearer $(API_KEY)" -d '{"flag_name": "enable-new-dashboard","is_enabled": true,"rules": {"type": "PERCENTAGE","value": 50}}'

key_validate:
	@if [ -z "$(CLUSTER_ENDPOINT)" ]; then echo "Defina CLUSTER_ENDPOINT."; exit 1; fi
	@if [ -z "$(API_KEY)" ]; then echo "Defina API_KEY."; exit 1; fi
	curl http://$(CLUSTER_ENDPOINT)/auth-service/validate -H "Authorization: Bearer $(API_KEY)"

test_auth:
	@if [ -z "$(CLUSTER_ENDPOINT)" ]; then echo "Defina CLUSTER_ENDPOINT."; exit 1; fi
	curl http://$(CLUSTER_ENDPOINT)/auth-service/health

test_flag:
	@if [ -z "$(CLUSTER_ENDPOINT)" ]; then echo "Defina CLUSTER_ENDPOINT."; exit 1; fi
	curl http://$(CLUSTER_ENDPOINT)/flag-service/health

test_targeting:
	@if [ -z "$(CLUSTER_ENDPOINT)" ]; then echo "Defina CLUSTER_ENDPOINT."; exit 1; fi
	curl http://$(CLUSTER_ENDPOINT)/targeting-service/health

test_evaluation:
	@if [ -z "$(CLUSTER_ENDPOINT)" ]; then echo "Defina CLUSTER_ENDPOINT."; exit 1; fi
	curl http://$(CLUSTER_ENDPOINT)/evaluation-service/health

test_analytics:
	@if [ -z "$(CLUSTER_ENDPOINT)" ]; then echo "Defina CLUSTER_ENDPOINT."; exit 1; fi
	curl http://$(CLUSTER_ENDPOINT)/analytics-service/health

test_all: test_auth test_flag test_targeting test_evaluation test_analytics
