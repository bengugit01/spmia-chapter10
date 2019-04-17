echo "Launching $BUILD_NAME IN AMAZON ECS"
#Note: the following is not working anymore!  Need to seperate configure profile from the region.  See commands below:
#ecs-cli configure --region ap-southeast-2 --access-key $AWS_ACCESS_KEY --secret-key $AWS_SECRET_KEY --cluster spmia-tmx-dev

env="dev"
profile_name="spmia-${env}"
cluster_name="${profile_name}-cluster"

group_id="sg-0775bffeced4f315d"

# use role as created by AWS during manual cluster creation 
role_name="ecsInstanceProfileMedium"
tier_class="t2.large"
keypair="mykey"
service_name="spmia-service-${env}"

echo "[*] [$( date +'%H:%M:%S')] Configure ECS profile..."
ecs-cli configure profile --profile-name ${profile_name} --access-key $AWS_ACCESS_KEY --secret-key $AWS_SECRET_KEY

echo "[*] [$( date +'%H:%M:%S')] Configure ECS cluster before launch..."
ecs-cli configure --region ap-southeast-2  --cluster ${cluster_name} --default-launch-type EC2 --config-name ${profile_name} 		
			
#echo "[*] [$( date +'%H:%M:%S')] Bring up EC2 instance..."
# bring up cluster
#ecs-cli up  --cluster-config ${profile_name} --ecs-profile ${profile_name} --instance-role ${role_name}

echo ""
echo "[*] [$( date +'%H:%M:%S')] Bring up EC2 instance..."
# bring up cluster
ecs-cli up  --instance-type ${tier_class}  --vpc ${vpc_id} --cluster-config ${profile_name} --subnets ${subnet_id_1},${subnet_id_2} --security-group ${group_id}  --instance-role ${role_name} --keypair ${keypair} --ecs-profile ${profile_name}

echo ""
echo "[*] [$( date +'%H:%M:%S')] Create Services in ECS cluster as defined in docker-compose.yml..."
ecs-cli compose --file docker/common/docker-compose.yml --cluster-config ${profile_name} --project-name ${service_name} service up
rm -rf ~/.ecs


