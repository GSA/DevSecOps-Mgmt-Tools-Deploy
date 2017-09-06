TERRAFORM_DIR := terraform
PLAYBOOK_DIR := playbooks
SSH_USER := ec2-user
INVENTORY_PATH := $(shell which terraform-inventory)

all: terraform ansible

install_roles:
	ansible-galaxy install -p roles/external -r requirements.yml

init:
	cd ../$(TERRAFORM_DIR) && terraform init -backend-config="backends.tfvars"

plan:
	cd ../$(TERRAFORM_DIR) && terraform plan

.PHONY: terraform
apply:
	cd ../$(TERRAFORM_DIR) && terraform apply && terraform state pull > terraform.tfstate

.PHONY: ansible
ansible: install_roles init plan apply install_jenkins

debug: install_roles init plan apply install_jenkins_debug

install_jenkins:
	cd $(PLAYBOOK_DIR) && TF_STATE=../../$(TERRAFORM_DIR)/terraform.tfstate ansible-playbook -i $(INVENTORY_PATH) --become --user=$(SSH_USER) jenkins-master.yml --vault-password-file .vault_pass.txt

install_jenkins_debug:
	cd $(PLAYBOOK_DIR) && TF_STATE=../../$(TERRAFORM_DIR)/terraform.tfstate ansible-playbook -vvvv -i $(INVENTORY_PATH) --become --user=$(SSH_USER) jenkins-master.yml --vault-password-file .vault_pass.txt

destroy:
	cd ../$(TERRAFORM_DIR) && terraform destroy

validate_terraform:
	cd ../$(TERRAFORM_DIR) && terraform validate

validate_ansible:
	cd $(PLAYBOOK_DIR) && ansible-playbook --syntax-check test.yml

validate: validate_terraform validate_ansible
