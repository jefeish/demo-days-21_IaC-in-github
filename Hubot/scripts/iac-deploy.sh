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
#/          iac-deploy.sh -a apply -c aws -v 2.22.13 -o jefeish
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
CMD="terraform"
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

echo "Starting to run a Terraform '${ACTION}' job for '${OWNER}'" >> ${HUBOT_LOG}

if [[ ! "${PROVIDER}" =~ ^aws$|^azure$ ]]; then
    echo "@${OWNER} I am sorry I don't know the target environment [${PROVIDER}]"
    exit 1
fi

# set the Terraform environment
TERRAFORM_PLAN_PATH="$(PWD)/../IaC/terraform/ghes/$(echo ${PROVIDER}| awk '{ print tolower($0) }')"
TERRAFORM_STATE_PATH="./state/${OWNER}/terraform.tfstate"

# switch to the Terraform IaC
cd ${TERRAFORM_PLAN_PATH}/

# if the state-file path does not exist, create it
[ ! -d "./state/${OWNER}/" ] && mkdir -p ./state/${OWNER}/

${CMD} init -no-color 2>&1 > ${HUBOT_LOG}

if [ "$?" = "1" ]; then
    echo ":wave: @${OWNER}, failed to initialize"
    exit 1
else
    echo "${OWNER}, I initialized GHES (v${VERSION})" >> ${HUBOT_LOG}
fi

echo ":wave: @${OWNER}, I am now working on your Infrastructure request... this might take moment"

echo 'yes' | ${CMD} ${ACTION} -no-color -var="stack_name=${OWNER}" -var="ghes_version=${VERSION}" -state=${TERRAFORM_STATE_PATH} 2>&1 >> ${HUBOT_LOG}

if [ "$?" = "1" ]; then
    echo ":wave: @${OWNER}, sorry but I failed to complete your GHES (v${VERSION}) infrastructure request "
    exit 1
else
    echo ":wave: @${OWNER}, I am finished"
    # 'destroy' does not have terraform output
    if [ "${ACTION}" = "apply" ]; then
        echo "$(${CMD} output -no-color -state=${TERRAFORM_STATE_PATH} )"
    fi
fi
