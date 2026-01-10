# Sane defaults
SHELL := /bin/bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

SELF_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

.DEFAULT_GOAL: _DEFAULT
.PHONY: _DEFAULT
_DEFAULT: ; @echo -n ""
# ---------------------- Includes ---------------------------
ifdef GLOBAL_MAKEFILE_LIBRARY
  include $(wildcard $(GLOBAL_MAKEFILE_LIBRARY)/*.mk)
endif

# ---------------------- COMMANDS ---------------------------
# Default params
STACK_NAME ?= aws-cfn-using-outputs-from-terraform
PARAMETERS ?= 

.PHONY: cfn-init
cfn-init: # Initialize a CloudFormation Stack with no resources 
	@aws cloudformation deploy \
		--template-file cloudformation/01-empty/stack.template.yaml \
		--stack-name $(STACK_NAME)

.PHONY: cfn-describe
cfn-describe: # Describe the CloudFormation stack
	@aws cloudformation describe-stacks \
		--no-cli-pager \
		--stack-name $(STACK_NAME) \
		--output table

.PHONY: cfn-destroy
cfn-destroy: # Teardown the CloudFormation stack 
	@aws cloudformation delete-stack \
		--stack-name $(STACK_NAME)

.PHONY: tf-stack
tf-stack: # Provision an CloudFormation Stack using Terraform for outputs
	terraform -chdir=./modules/terraform-aws-cloudformation-outputs init
	terraform -chdir=./modules/terraform-aws-cloudformation-outputs apply -auto-approve

.PHONY: cfn-props
cfn-props: # Provision a CloudFormation Stack including boilerplate for a Parameter store entry
	@aws cloudformation deploy \
		--template-file cloudformation/02-properties/stack.template.yaml \
		--stack-name $(STACK_NAME)

.PHONY: tf-destroy
tf-destroy: # Provision an S3 bucket containing parameter store entries for SSM
	terraform -chdir=./modules/terraform-aws-cloudformation-outputs destroy -auto-approve