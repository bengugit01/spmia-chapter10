echo "Pushing service docker images to docker hub ...."
docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD
docker push bengugit01/tmx-authentication-service:$BUILD_NAME
docker push bengugit01/tmx-licensing-service:$BUILD_NAME
docker push bengugit01/tmx-organization-service:$BUILD_NAME
docker push bengugit01/tmx-confsvr:$BUILD_NAME
docker push bengugit01/tmx-eurekasvr:$BUILD_NAME
docker push bengugit01/tmx-zuulsvr:$BUILD_NAME
