#!/usr/bin/env bash

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
#stack_name="instancestack"

get_instance_id() {
    json=$(aws cloudformation describe-stack-resources --stack-name $1 --logical-resource-id Ec2Instance)
    echo $json | python -c "import sys; import json; print json.loads(sys.stdin.read())['StackResources'][0]['PhysicalResourceId']"
}



#stack_name="instancestack"
#aws cloudformation describe-stacks --stack-name $stack_name
#exit

region="us-west-2"
instance_size="t2.small"
template_name="mini_project_template.json"


aws cloudformation validate-template --template-body file://$TEMPLATE_FILEPATH
create_stack() { 

    aws cloudformation create-stack --stack-name "$1" --region "$region" --parameters ParameterKey=InstanceType,ParameterValue="$instance_size" --template-body file://$TEMPLATE_DIR/$template_name

}

delete_stack() {

    aws cloudformation delete-stack --stack-name "$1"
    while stack_exists $1
    do 
        echo "sleeping"
        sleep 2 
   done
}

stack_exists() {
    if  aws cloudformation describe-stacks --stack-name $1 &> //dev/null
    then
        return 0
    else
        return 1
    fi 
}

if stack_exists $stack_name
then
    echo "deleting stack with name: $stack_name "

    delete_stack $stack_name
    echo "creating stack with name: $stack_name "

    create_stack $stack_name
    echo "create complete"

    #if [ "$clobber" = "yes" ] 
    #then
    #    echo "deleting stack with name: $stack_name "
    #    delete_stack $stack_name

    #else
    #    echo "stack with name: $stack_name already exists, but clobber is set to no. Nothing will be changed." 
    #    exit
    #fi 
else
    echo "creating stack with name: $stack_name "

    create_stack $stack_name
    echo "create complete"
fi


sleep 120

instance_id=$(get_instance_id $stack_name)
echo $instance_id

python ../tests/post_deploy_tests.py $instance_id

#aws cloudformation update-stack --stack-name "$stack_name" --region "$region" --parameters ParameterKey=KeyName,ParameterValue="$keypair_name" ParameterKey=InstanceType,ParameterValue="$instance_size" --template-body file://$TEMPLATE_DIR/$template_name



