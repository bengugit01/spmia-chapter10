echo "Launching $BUILD_NAME IN AMAZON ECS"
#ecs-cli configure --region ap-southeast-2 --access-key $AWS_ACCESS_KEY --secret-key $AWS_SECRET_KEY --cluster spmia-tmx-dev

profile_name="spmia-example"
role_name="ECSExampleRole"

echo "[*] [$( date +'%H:%M:%S')] Creating IAM role for ECS instances... (gives you possibility to use your ECR - AWS private registry for example"
create_role_response=$( aws iam create-role --role-name ${role_name} --assume-role-policy-document file://ecs-policy.json --description "ECS Cluster default role" )
put_role_policy_response=$( aws iam put-role-policy --role-name ${role_name} --policy-name ecsMediumRolePolicy --policy-document file://ecs-role.json ) 

create_instance_profile_response=$( aws iam create-instance-profile --instance-profile-name ecsInstanceProfileMedium )
add_role_to_instance_response=$( aws iam add-role-to-instance-profile --instance-profile-name ecsInstanceProfileMedium --role-name ${role_name} )

echo "[*] [$( date +'%H:%M:%S')] Configure ECS profile..."
ecs-cli configure profile --profile-name ${profile_name} --access-key $AWS_ACCESS_KEY --secret-key $AWS_SECRET_KEY

echo "[*] [$( date +'%H:%M:%S')] Configure ECS cluster before launch..."
ecs-cli configure --region ap-southeast-2  --cluster spmia-tmx-dev --default-launch-type EC2 --config-name ${profile_name} 		
			
echo "[*] [$( date +'%H:%M:%S')] Bring up EC2 instance..."
# bring up cluster
ecs-cli up  --cluster-config ${profile_name} --ecs-profile ${profile_name} --instance-role ${role_name}

echo "[*] [$( date +'%H:%M:%S')] Create Services in ECS cluster as defined in docker-compose.yml..."
ecs-cli compose --file docker/common/docker-compose.yml --cluster-config ${profile_name} up
rm -rf ~/.ecs