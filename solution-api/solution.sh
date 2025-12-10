#!/bin/bash

# Variables
AWS_REGION="eu-north-1"
ACCOUNT_ID="780202038201"
REPO_NAME="custody-solution-api"
ECR_URL="$ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME"
YAML_FILE="Custody_Solution_Api.yml"

# Login to ECR
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

# Extract last tag from YAML file
CURRENT_IMAGE_LINE=$(grep "image: " $YAML_FILE)
CURRENT_TAG=$(echo "$CURRENT_IMAGE_LINE" | awk -F: '{print $3}')


echo "Current tag in YAML: $CURRENT_TAG"

# Increment the tag
NEW_TAG=$((CURRENT_TAG + 1))
echo "New tag will be: $NEW_TAG"

# Build and push Docker image
docker build -t $ECR_URL:$NEW_TAG .
docker push $ECR_URL:$NEW_TAG

# Update YAML file to use new tag
sed -i.bak "s|image: .*|image: $ECR_URL:$NEW_TAG|" $YAML_FILE

# (Optional) Apply updated deployment to Kubernetes
# kubectl apply -f $YAML_FILE

echo "Deployment updated to tag $NEW_TAG"
