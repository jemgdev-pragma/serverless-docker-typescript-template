# A docker with serverless infrastructure application template

This project provides a template to use in a docker project with serverless tools and CI/CD with GitHub Actions.

## Environment Variables

To deploy this project, you will need to config the following environment variables to your workflows.

`AWS_REGION, Example: us-east-1`

`ECR_REPOSITORY, Example: template-image-dev`

`IMAGE_TAG, Example: latest`

`CLUSTER_NAME, Example: template-cluster-dev`

`SERVICE_NAME, Example: template-ecs-service-dev`

`ENVIRONMENT, Example: dev`

Then you must also need to configure this secrets in GitHub Secrets:

`AWS_ACCESS_KEY_ID [Your access key id from IAM user]`

`AWS_SECRET_ACCESS_KEY [Your secret access key from IAM user]`

`AWS_ACCOUNT_ID [Your account id]`

`VPC_ID [Your vpc id]`

`SUBNET_ID [Your public subnet id in the vpc]`

## Deployment
This repository follow the Trunk Based version strategy. Then for deploy in develop environment you must to create a branch feature/* to main branch.

When PR is closed, GitHub Actions will deploy in production environment.