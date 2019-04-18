echo "Launching $BUILD_NAME IN AMAZON ECS"
#Note: the following is not working anymore!  Need to seperate configure profile from the region.  See commands below:
#ecs-cli configure --region ap-southeast-2 --access-key $AWS_ACCESS_KEY --secret-key $AWS_SECRET_KEY --cluster spmia-tmx-dev

env="dev"
profile_name="spmia-${env}"
cluster_name="${profile_name}-cluster"

tier_class="t2.large"
keypair="mykey"
service_name="spmia-service-${env}"


# Note:  the following are created by 
#	deploy_to_amazon_ecs_createVPC.sh
#   deploy_to_amazon_ecs_create_role_instancProfile.sh
vpc_id=vpc-07d6c1b46ad4ac180
region=ap-southeast-2
subnet_id_1=subnet-059f277140f66d303
subnet_id_2=subnet-0067c05ad6c3782d4
group_id=sg-0775bffeced4f315d
instance_profile_name="spmia-dev-InstanceProfile"
role_name="spmia-dev-Role"

echo "[*] [$( date +'%H:%M:%S')] Configure ECS profile..."
ecs-cli configure profile --profile-name ${profile_name} --access-key $AWS_ACCESS_KEY --secret-key $AWS_SECRET_KEY

echo "[*] [$( date +'%H:%M:%S')] Configure ECS cluster before launch..."
ecs-cli configure --region ap-southeast-2  --cluster ${cluster_name} --default-launch-type EC2 --config-name ${profile_name} 		

	
echo ""
echo "Checking the environment variables set:"
echo "   vpc_id = ${vpc_id}"	
echo "   profile_name = ${profile_name}"	
echo "   subnet_id_1 = ${subnet_id_1}"	
echo "   subnet_id_2 = ${subnet_id_2}"	
echo "   group_id = ${group_id}"	
echo "   instance_profile_name = ${instance_profile_name}"	
echo "   role_name = ${role_name}"	
echo ""
echo "[*] [$( date +'%H:%M:%S')] Bring up EC2 instance..."
# bring up cluster
ecs-cli up  --instance-type ${tier_class}  --vpc ${vpc_id} --cluster-config ${profile_name} --subnets ${subnet_id_1},${subnet_id_2} --security-group ${group_id}  --instance-role ${instance_profile_name}  --keypair ${keypair} --ecs-profile ${profile_name}

echo ""
echo "[*] [$( date +'%H:%M:%S')] Create Services in ECS cluster as defined in docker-compose.yml..."
ecs-cli compose --file docker/common/docker-compose.yml --cluster-config ${profile_name} --project-name ${service_name} service up
rm -rf ~/.ecs


