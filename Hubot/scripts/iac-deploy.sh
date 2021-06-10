#! /bin/bash

# -------------------------------------------------------------------------------
#/ 
#/  Mini script to deploy Terraform based IaC to multi cloud
#/ 
#/  USAGE
#/
#/      iac-deploy.sh -a <apply|destroy> -c <aws|azure> -v <version> -o <owner>
#/   
#/      Example:
#/          iac-deploy.sh 
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
TERRAFORM_PLAN_PATH="/Users/jefeish/projects/demo-days-21_IaC-in-github/IaC/terraform/ghes/$(echo ${PROVIDER}| awk '{ print tolower($0) }')"
TERRAFORM_STATE_PATH="./state/${OWNER}/${VERSION}/terraform.tfstate"

# execute the Terraform IaC
# echo "cd  ${TERRAFORM_PLAN_PATH}/ && terraform ${ACTION} -var=\"ghes_version=${VERSION}\" -state=${TERRAFORM_STATE_PATH}"
cd ${TERRAFORM_PLAN_PATH}/

r1=$(terraform-v0.15.0 init -no-color)

if [ "$?" = "1" ]; then
    echo "@${OWNER} :wave:, failed to initialize"
    exit 1
else
    echo "@${OWNER} :wave:, initialized GHES (v${VERSION})"
fi

echo ":wave: @${OWNER}, now building your _IaC_"
set -x
echo 'yes' | terraform-v0.15.0 ${ACTION} -state=${TERRAFORM_STATE_PATH}

if [ "$?" = "1" ]; then
    echo ":wave: @${OWNER}, sorry but I failed to stand up your GHES (v${VERSION}) infrastructure :( "
    echo ">>>> $r2"
    exit 1
else
    r3=$(terraform-v0.15.0 output -no-color -state=${TERRAFORM_STATE_PATH} )
    echo $r3
fi
