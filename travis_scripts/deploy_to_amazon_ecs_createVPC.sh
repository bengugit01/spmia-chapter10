#!/bin/bash
# Description: Scripts to create VPC, security-group and authorize access to port 22 and 5555 etc.
# By:   Ben
# Date: 17/4/2019

export AWS_ACCESS_KEY_ID=AKIATTJ5K5Q74BGKVT6L
export AWS_SECRET_ACCESS_KEY=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


env="dev"
name="spmia-${env}"
region="ap-southeast-2"
vpc_name="${name} VPC"

#loadbalancer_name="${cluster_name}-loadbalancer"
#loadbalancer_targets_name="${cluster_name}-targets"

#role_name="ECSExampleRole"


availability_zone_1="ap-southeast-2a"
availability_zone_2="ap-southeast-2b"

subnet_name_1="${name} Subnet 1"
subnet_name_2="${name} Subnet 2"

#Ben 17/4/2019: commented out gateway
#gateway_name="${name} Gateway"

route_table_name="${name} Route Table"
security_group_name="${name} Security Group"
vpc_cidr_block="10.0.0.0/16"
subnet_cidr_block_1="10.0.1.0/24"
subnet_cidr_block_2="10.0.2.0/24"

# allow traffic on these ports from anywhere
port_cidr_block_5555="0.0.0.0/0"
port_cidr_block_22="0.0.0.0/0"
#port_cidr_block_80="0.0.0.0/0"
#port_cidr_block_443="0.0.0.0/0"

# allow traffic out anywhere
destination_cidr_block="0.0.0.0/0"

# creating VPC part comes from here! https://medium.com/@brad.simonin/create-an-aws-vpc-and-subnet-using-the-aws-cli-and-bash-a92af4d2e54b
# it was modified to support multiple ports/zones
echo ""
echo "[*] [$( date +'%H:%M:%S')] Creating VPC..."
aws_response=$(aws --region ${region} ec2 create-vpc  --cidr-block "$vpc_cidr_block"  --output json)
vpc_id=$(echo -e "$aws_response" |  jq '.Vpc.VpcId' | tr -d '"')
aws --region ${region} ec2 create-tags  --resources "${vpc_id}" --tags Key=Name,Value="${vpc_name}"
modify_response=$(aws --region ${region} ec2 modify-vpc-attribute --vpc-id "${vpc_id}" --enable-dns-support "{\"Value\":true}")
modify_response=$(aws --region ${region} ec2 modify-vpc-attribute --vpc-id "${vpc_id}" --enable-dns-hostnames "{\"Value\":true}")

#Ben 17/4/2019: commented out gateway
#gateway_response=$(aws --region ${region} ec2 create-internet-gateway --output json)
#gateway_id=$(echo -e "${gateway_response}" |  jq '.InternetGateway.InternetGatewayId' | tr -d '"')
#aws --region ${region} ec2 create-tags --resources "${gateway_id}" --tags Key=Name,Value="${gateway_name}"
#attach_response=$(aws --region ${region} ec2 attach-internet-gateway --internet-gateway-id "${gateway_id}" --vpc-id "${vpc_id}")

subnet_response_1=$(aws --region ${region} ec2 create-subnet --cidr-block "${subnet_cidr_block_1}" --availability-zone "${availability_zone_1}" --vpc-id "${vpc_id}"  --output json)
subnet_id_1=$(echo -e "$subnet_response_1" |  jq '.Subnet.SubnetId' | tr -d '"')
aws --region ${region} ec2 create-tags --resources "${subnet_id_1}" --tags Key=Name,Value="${subnet_name_1}"
modify_response=$(aws --region ${region} ec2 modify-subnet-attribute --subnet-id "${subnet_id_1}" --map-public-ip-on-launch)

subnet_response_2=$(aws --region ${region} ec2 create-subnet --cidr-block "${subnet_cidr_block_2}" --availability-zone "${availability_zone_2}" --vpc-id "${vpc_id}"  --output json)
subnet_id_2=$(echo -e "${subnet_response_2}" |  jq '.Subnet.SubnetId' | tr -d '"')
aws --region ${region} ec2 create-tags --resources "${subnet_id_2}" --tags Key=Name,Value="${subnet_name_2}"
modify_response=$(aws --region ${region} ec2 modify-subnet-attribute --subnet-id "${subnet_id_2}" --map-public-ip-on-launch)

echo "[*] [$( date +'%H:%M:%S')] ec2 create-security-group..."
security_response=$(aws --region ${region} ec2 create-security-group  --group-name "${security_group_name}"  --description "Private: ${security_group_name}"  --vpc-id "${vpc_id}" --output json)
group_id=$(echo -e "${security_response}" |  jq '.GroupId' | tr -d '"')
aws --region ${region} ec2 create-tags --resources "${group_id}" --tags Key=Name,Value="${security_group_name}"

# enable port 22,80,443
echo ""
echo "[*] [$( date +'%H:%M:%S')] ec2 authorize-security-group-ingress for port 22 and 5555..."
security_response_1=$(aws --region ${region} ec2 authorize-security-group-ingress --group-id "${group_id}" --protocol tcp --port 22 --cidr "$port_cidr_block_22")
security_response_2=$(aws --region ${region} ec2 authorize-security-group-ingress --group-id "${group_id}" --protocol tcp --port 5555 --cidr "$port_cidr_block_5555")
#security_response_3=$(aws --region ${region} ec2 authorize-security-group-ingress --group-id "${group_id}" --protocol tcp --port 443 --cidr "$port_cidr_block_443")

# authorize traffic from same security group (registering ecs)
security_response4=$(aws --region ${region} ec2 authorize-security-group-ingress --group-id "${group_id}" --protocol tcp --port 0-65535 --source-group ${group_id})

route_table_response=$(aws --region ${region} ec2 create-route-table --vpc-id "${vpc_id}" --output json)
route_table_id=$(echo -e "${route_table_response}" | jq '.RouteTable.RouteTableId' | tr -d '"')
aws --region ${region} ec2 create-tags --resources "${route_table_id}"  --tags Key=Name,Value="${route_table_name}"

#add route for the internet gateway
#Ben 17/4/2019: commented out gateway
#route_response=$(aws --region ${region} ec2 create-route  --route-table-id "${route_table_id}"  --destination-cidr-block "${destination_cidr_block}"  --gateway-id "${gateway_id}")

associate_response_1=$(aws --region ${region} ec2 associate-route-table --subnet-id "${subnet_id_1}" --route-table-id "${route_table_id}")
associate_response_2=$(aws --region ${region} ec2 associate-route-table --subnet-id "${subnet_id_2}" --route-table-id "${route_table_id}")
echo " "
echo "[*] [$( date +'%H:%M:%S')] VPC created, VPC ID: ${vpc_id}"
echo "[*] [$( date +'%H:%M:%S')] Use Subnet ID $subnet_id_1 and $subnet_id_2, for Security Group ID ${group_id}"
echo "[*] [$( date +'%H:%M:%S')] AWS resources will be created in $region, and in these AZs: $availability_zone_1, $availability_zone_2"

echo "[*] [$( date +'%H:%M:%S')] Dumping values for future usage to ecs_vpc.values file..."
echo "vpc_id=${vpc_id}" > ecs_vpc.values
echo "region=$region" >> ecs_vpc.values
echo "subnet_id_1=$subnet_id_1" >> ecs_vpc.values
echo "subnet_id_2=$subnet_id_2" >> ecs_vpc.values
echo "group_id=${group_id}" >> ecs_vpc.values

echo ""
echo "commented out the creation of role as it already created before. "
echo "TBF:  write code to query if role ECSExampleRole exists or not, if not, run the following role-creation codes !!!"
echo "[*] [$( date +'%H:%M:%S')] Creating IAM role for ECS instances... (gives you possibility to use your ECR - AWS private registry for example"
#create_role_response=$( aws iam create-role --role-name ${role_name} --assume-role-policy-document file://ecs-policy.json --description "ECS Cluster default role" )

# put_role_policy_response=$( aws iam put-role-policy --role-name ${role_name} --policy-name ecsMediumRolePolicy --policy-document file://ecs-role.json ) 