#! /bin/bash

# -------------------------------------------------------------------------------
#/ 
#/  Mini script to deploy Terraform based IaC to multi cloud
#/ 
#/  USAGE
#/
#/      iac-deploy.sh <provider> <version> <apply|destroy>
#/   
#/      Example:
#/          iac-deploy.sh aws 3.0.1 apply
#/
#/
#/  REQUIREMENTS:
#/      AWS or Azure login credential have to be provided.
#/
#/      AWS reference: https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication
#/
#/      Azure reference: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret        
#/
#/
#/
# -------------------------------------------------------------------------------

PROVIDER=""
ACTION="plan"
VERSION="3.1.0"
OWNER="demo"

function usage() {
    grep '^#/' <"$0" | cut -c4-
    exit 0
}

# ----------------------------------------------------------------------------
# commandline options
# ----------------------------------------------------------------------------
if [ $# -eq 8 ]; then
    while getopts a:c:o:v: option; do
        case "${option}" in

        a) ACTION=${OPTARG} ;;
        c) PROVIDER=${OPTARG} ;;
        o) OWNER=${OPTARG} ;;
        v) VERSION=${OPTARG} ;;
        *)
            echo "Invalid parameter detected"
            usage
            ;;
        esac
    done
else
    usage
fi

# set the Terraform environment
TERRAFORM_PLAN_PATH="../../IaC/terraform/ghes/$(echo ${PROVIDER}| awk '{ print tolower($0) }')"
TERRAFORM_STATE_PATH="./state"

# execute the Terraform IaC
echo "cd  ${TERRAFORM_PLAN_PATH}/ && terraform ${ACTION} -var=\"ghes_version=${VERSION}\" -state=${TERRAFORM_STATE_PATH}/${OWNER}/${VERSION}/terraform.tfstate"
cd ${TERRAFORM_PLAN_PATH}/ && terraform init && echo "yes" | terraform ${ACTION} -state=${TERRAFORM_STATE_PATH}/${OWNER}/${VERSION}/terraform.tfstate 
