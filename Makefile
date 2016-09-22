AWS_DEFAULT_REGION := $(shell ./bin/get_setting AWS_DEFAULT_REGION)
STACK_NAME := $(shell ./bin/get_setting DOCKER_STACK_NAME)
TEMPLATE = "file://./cfn.json"

ACTION ?= $(shell aws cloudformation describe-stacks --stack-name $(STACK_NAME) &>/dev/null && echo update || echo create)

deploy:
	@aws cloudformation $(ACTION)-stack    \
	  --region "$(AWS_DEFAULT_REGION)"     \
	  --stack-name "$(STACK_NAME)"         \
	  --template-body "$(TEMPLATE)"        \
	  --capabilities CAPABILITY_IAM        \
	  2>&1
	@aws cloudformation wait stack-$(ACTION)-complete \
	  --stack-name $(STACK_NAME)
