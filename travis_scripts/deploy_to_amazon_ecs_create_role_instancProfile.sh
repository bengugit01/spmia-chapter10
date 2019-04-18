#!/bin/bash
# Description: Scripts to create IAM role for ECS instances
# By:   Ben
# Date: 17/4/2019
# Note:  need to set environment variables on the command line:
# export AWS_ACCESS_KEY_ID=
# export AWS_SECRET_ACCESS_KEY=
#
#
env="dev"
name="spmia-${env}"

role_name="${name}-Role"
policy_name="${name}-RolePolicy" 
instance_profile_name="${name}-InstanceProfile" 

echo ""
echo "[*] [$( date +'%H:%M:%S')] Creating IAM role for ECS instances..."
create_role_response=$( aws iam create-role --role-name ${role_name} --assume-role-policy-document file://ecs-policy.json --description "ECS Cluster default role" )

put_role_policy_response=$( aws iam put-role-policy --role-name ${role_name} --policy-name ${policy_name}  --policy-document file://ecs-role.json ) 

echo ""
create_instance_profile_response=$( aws iam create-instance-profile --instance-profile-name ${instance_profile_name}  )
add_role_to_instance_response=$( aws iam add-role-to-instance-profile --instance-profile-name ${instance_profile_name} --role-name ${role_name} )

