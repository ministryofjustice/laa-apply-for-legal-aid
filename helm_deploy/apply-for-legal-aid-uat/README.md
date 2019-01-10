# Helm Deploy

This describes the setup for helm and what is required to be in place to perform deploys.

## CI configuration

In order for a deploy to be successful, a set of configurations need to be in place:

* `APPLICATION_DEPLOY_NAME` - name of the deployable app
* `<ENV>_HOST` - base hostname for the deployable app
* `GIT_CRYPT_KEY` - key to allow the decription of secrets required for deploy
* `KUBE_ENV_<ENV>_NAME`
* `KUBE_ENV_<ENV>_NAMESPACE`
* `KUBE_ENV_<ENV>_CACERT`
* `KUBE_ENV_<ENV>_TOKEN`

For more information on how to correctly configure CircleCI to be able to deploy to the K8S environment, click [here](https://ministryofjustice.github.io/cloud-platform-user-docs/02-deploying-an-app/004-use-circleci-to-upgrade-app/#add-variables-to-circleci).

## Deploy

Deploys are normally triggered through CI (CircleCI) after a branch is pushed to the repo (they require manual approval in order to be initiated).

**NOTE:** A manually deploy can be triggered through the developer's console by executing the same command that CircleCI executes to trigger the deploy (refer to the `.circleci/config.yml` for more details).
