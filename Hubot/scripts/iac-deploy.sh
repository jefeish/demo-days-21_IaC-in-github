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
CMD="terraform-v0.15.0"
HUBOT_LOG="$PWD/hubot.log"

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

if [[ ! "${PROVIDER}" =~ ^aws$|^azure$ ]]; then
    echo "@${OWNER} I am sorry I don't know the target environment [${PROVIDER}]"
    exit 1
fi

# set the Terraform environment
TERRAFORM_PLAN_PATH="$(PWD)/../IaC/terraform/ghes/$(echo ${PROVIDER}| awk '{ print tolower($0) }')"
TERRAFORM_STATE_PATH="./state/${OWNER}/${VERSION}/terraform.tfstate"

# switch to the Terraform IaC
cd ${TERRAFORM_PLAN_PATH}/

# if the state-file path does not exist, create it
[ ! -d "./state/${OWNER}/${VERSION}/" ] && mkdir -p ./state/${OWNER}/${VERSION}/

${CMD} init -no-color 2>&1 > ${HUBOT_LOG}

if [ "$?" = "1" ]; then
    echo ":wave: @${OWNER}, failed to initialize"
    exit 1
else
    echo "${OWNER}, I initialized GHES (v${VERSION})" >> ${HUBOT_LOG}
fi

echo ":wave: @${OWNER}, I am now working on your IaC request... this might take moment"

echo 'yes' | ${CMD} ${ACTION} -no-color -var="ghes_version=${VERSION}" -state=${TERRAFORM_STATE_PATH} 2>&1 >> ${HUBOT_LOG}

if [ "$?" = "1" ]; then
    echo ":wave: @${OWNER}, sorry but I failed to complete your GHES (v${VERSION}) infrastructure request "
    exit 1
else
    echo ":wave: @${OWNER}, I am finished"
    echo "$(${CMD} output -no-color -state=${TERRAFORM_STATE_PATH} )"
fi
