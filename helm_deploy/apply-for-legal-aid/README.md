# Helm Deploy

This describes the setup for helm and what is required to be in place to perform deploys.

## CI configuration
The values are now stored in environment variables and contexts in circle ci - a full set of key value pairs can be found in 1Password.

For more information on how to correctly configure CircleCI to be able to deploy to the K8S environment, click [here](https://user-guide.cloud-platform.service.justice.gov.uk/documentation/deploying-an-app/using-circleci-for-continuous-deployment.html#add-variables-to-circleci).

## Deploy

Deploys are normally triggered through CI (CircleCI) after a branch is pushed to the repo, they require manual approval in order to complete deploy to production

**NOTE:** A manual deploy can be triggered through the developer's console by executing the same command that CircleCI executes to trigger the deploy (refer to the `.circleci/config.yml` for more details).
