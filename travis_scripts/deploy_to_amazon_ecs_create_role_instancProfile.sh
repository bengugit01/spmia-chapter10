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

echo "remove-role-from-instance-profile"
aws iam remove-role-from-instance-profile --instance-profile-name spmia-dev-InstanceProfile --role-name spmia-dev-Role


echo "delete-role-policy"
delete_role_policy_response=$( aws iam delete-role-policy --role-name spmia-dev-Role --policy-name spmia-dev-RolePolicy )
echo "delete_instance_profile_response returned =${delete_role_policy_response}"


echo "delete-role"
delete_role_response=$( aws iam delete-role --role-name spmia-dev-Role )
echo "delete_instance_profile_response returned =${delete_role_response}"

echo "delete-instance-profile"
delete_instance_profile_response=$( aws iam delete-instance-profile --instance-profile-name spmia-dev-InstanceProfile )
echo "delete_instance_profile_response returned =${delete_instance_profile_response}"


echo ""
echo "[*] [$( date +'%H:%M:%S')] Creating IAM role for ECS instances..."
create_role_response=$( aws iam create-role --role-name ${role_name} --assume-role-policy-document file://ecs-policy.json --description "ECS Cluster default role" )
echo "create_role_response returned =${create_role_response}"

echo ""
attach_role_policy_response=$( aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role --role-name ${role_name} ) 

echo "attach_role_policy_response returned =${attach_role_policy_response}"


echo ""
create_instance_profile_response=$( aws iam create-instance-profile --instance-profile-name ${role_name}  )
add_role_to_instance_response=$( aws iam add-role-to-instance-profile --instance-profile-name ${role_name} --role-name ${role_name} )
echo "create_instance_profile_response returned =${create_instance_profile_response}"
