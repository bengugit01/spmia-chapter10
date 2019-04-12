echo "Pushing service docker images to docker hub ...."
docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD
docker push bengu/tmx-authentication-service:$BUILD_NAME
docker push bengu/tmx-licensing-service:$BUILD_NAME
docker push bengu/tmx-organization-service:$BUILD_NAME
docker push bengu/tmx-confsvr:$BUILD_NAME
docker push bengu/tmx-eurekasvr:$BUILD_NAME
docker push bengu/tmx-zuulsvr:$BUILD_NAME
