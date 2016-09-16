AWS_DEFAULT_REGION := $(shell ./bin/get_setting AWS_DEFAULT_REGION)
STACK_NAME := $(shell ./bin/get_setting STACK_NAME)
TEMPLATE = "file://./cfn/docker.json"
KEYPAIR_NAME = "s3strm"
KEYPAIR_FILE = "./keypair.pem"

ACTION := $(shell aws cloudformation describe-stacks --stack-name $(STACK_NAME) &>/dev/null && echo update || echo create)
KEYPAIR_EXISTS := $(shell [[ -z $$( aws ec2 describe-key-pairs --key-names ${KEYPAIR_NAME} --output "text" 2>/dev/null ) ]] && echo false || echo true )

keypair:
ifeq "$(KEYPAIR_EXISTS)" "false"
	@aws ec2 create-key-pair            \
	  --key-name "${KEYPAIR_NAME}"      \
	  --output "text"                   \
	  --query 'KeyMaterial'             \
	  --region "$(AWS_DEFAULT_REGION)"  \
	  > $(KEYPAIR_FILE)
endif
	@chmod 600 $(KEYPAIR_FILE)

deploy: keypair
	@aws cloudformation $(ACTION)-stack    \
		--region "$(AWS_DEFAULT_REGION)"   \
		--stack-name "$(STACK_NAME)"       \
		--template-body "$(TEMPLATE)"      \
		--capabilities CAPABILITY_IAM      \
		2>&1
	@aws cloudformation wait stack-$(ACTION)-complete \
		--stack-name $(STACK_NAME)

