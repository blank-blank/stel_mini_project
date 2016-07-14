#!/usr/bin/env bash
set -e

if [ -z "$TEMPLATE_DIR" ]
then
    TEMPLATE_DIR="$(dirname $0)/templates"
fi
TEMPLATE_FILE="$1"
TEMPLATE_FILEPATH="${TEMPLATE_DIR}/${TEMPLATE_FILE}"

if [ -z $TEMPLATE_FILE ]
then
    echo "Usage: launch_cf_template template_file"
    exit 1
fi

if [ ! -f $TEMPLATE_FILEPATH ]
then
    echo $TEMPLATE_FILEPATH
    echo "TEMPLATE_FILEPATH does not exist" 
    exit 1
fi
stack_name="miniProjectStack"
region="us-west-2"
keypair_name="tim_keypair"
instance_size="t2.small"
template_name="mini_project_template.json"

aws cloudformation validate-template --template-body file://$TEMPLATE_FILEPATH

aws cloudformation create-stack --stack-name "$stack_name" --region "$region" --parameters ParameterKey=KeyName,ParameterValue="$keypair_name" ParameterKey=InstanceType,ParameterValue="$instance_size" --template-body file://$TEMPLATE_DIR/$template_name
