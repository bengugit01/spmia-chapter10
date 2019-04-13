echo "Launching $BUILD_NAME IN AMAZON ECS"
#ecs-cli configure --region ap-southeast-2 --access-key $AWS_ACCESS_KEY --secret-key $AWS_SECRET_KEY --cluster spmia-tmx-dev

ecs-cli configure profile --profile-name edXProjectUser --access-key $AWS_ACCESS_KEY --secret-key $AWS_SECRET_KEY

ecs-cli configure --region ap-southeast-2  --cluster spmia-tmx-dev --default-launch-type FARGATE

ecs-cli compose --file docker/common/docker-compose.yml up
rm -rf ~/.ecs
