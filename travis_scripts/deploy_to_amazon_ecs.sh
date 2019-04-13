echo "Launching $BUILD_NAME IN AMAZON ECS"
#ecs-cli configure --region ap-southeast-2 --access-key $AWS_ACCESS_KEY --secret-key $AWS_SECRET_KEY --cluster spmia-tmx-dev

profile_name="spmia-example"

echo "[*] [$( date +'%H:%M:%S')] Configure ECS profile..."
ecs-cli configure profile --profile-name ${profile_name} --access-key $AWS_ACCESS_KEY --secret-key $AWS_SECRET_KEY

echo "[*] [$( date +'%H:%M:%S')] Configure ECS cluster before launch..."
ecs-cli configure --region ap-southeast-2  --cluster spmia-tmx-dev --default-launch-type EC2 --config-name ${profile_name} 		
			
echo "[*] [$( date +'%H:%M:%S')] Bring up EC2 instance..."
# bring up cluster
ecs-cli up  --cluster-config ${profile_name} --ecs-profile ${profile_name}

echo "[*] [$( date +'%H:%M:%S')] Create Services in ECS cluster as defined in docker-compose.yml..."
ecs-cli compose --file docker/common/docker-compose.yml --cluster-config ${profile_name} up
rm -rf ~/.ecs