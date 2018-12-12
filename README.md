DO NOT MERGE TESTING ONLY
# LAA Apply for legal aid

This is the service api for persisting application related information to the back end database and
may well be used to fire requests to other services.

[![CircleCI](https://circleci.com/gh/ministryofjustice/laa-apply-for-legal-aid/tree/master.svg?style=svg)](https://circleci.com/gh/ministryofjustice/laa-apply-for-legal-aid/tree/master)

* Ruby version
    * Ruby version 2.5.1
    * Rails 5

* System dependencies
    * postgres 10.5
    * npm

Install dependencies with homebrew:
```
brew bundle
```

## Initial setup

```
# From the root of the project execute the following command:
bin/setup
```

**NOTE:** Ensure the `.env.development` settings are correctly configured.

### Run the application server

```
bin/rails s
```

### Running tests

Runs Rubocop, RSpec specs and Cucumber features

```
bin/rake
```

**NOTE:** To ensure the recorded VCRs used in the specs are up to date, run the tests as such:

```
VCR_RECORD_MODE=all bin/rake
```

[There is an (deprecated) alternative setup procedure (not recommended), using the makefile, which can be found here](./docs/README_alt.md)

## Deployment

The deployment is triggered on all builds in [CircleCI](https://circleci.com/gh/ministryofjustice/laa-apply-for-legal-aid) but requires approval to the desired environment.

**NOTE:** **git-crypt** is required to store secrets required for **uat**, **staging** and **production** environments. To be able to modify those secrets, **git-crypt** needs to be set up according to the following [guide](https://ministryofjustice.github.io/cloud-platform-user-docs/03-other-topics/001-git-crypt-setup/#git-crypt).

* For more information on howto setup **Helm** in your local environment refer to the following [guide](https://ministryofjustice.github.io/cloud-platform-user-docs/02-deploying-an-app/002-app-deploy-helm/#installing-and-configuring-helm-and-tiller).
* For more deployment information refer to the specific [README](./helm_deploy/apply-for-legal-aid/README.md)

### UAT Deployments

**NOTE: Until an automated process is put in place to deal with this issue, once a branch has been merged into master or deleted, for which there's an associated release, the following commands should be executed to ensure those releases are deleted, as they're no longer necessary:**

```
# list the availables releases:
helm list --tiller-namespace=laa-apply-for-legalaid-uat --namespace=laa-apply-for-legalaid-uat --debug --all

# delete a specific release
helm delete <name-of-the-release> --tiller-namespace=laa-apply-for-legalaid-uat --purge
```

## 3rd party integrations

### True Layer

To connect the True Layer API, a client ID and client SECRET must be supplied. They can be
set via the environment variables `TRUE_LAYER_CLIENT_ID` and `TRUE_LAYER_CLIENT_SECRET`
respectively. Visit https://console.truelayer.com to get a client ID and client SECRET.

True Layer offer a Mock Bank option (see https://docs.truelayer.com/#mock-users). To enable
this functionality, set the environment variable `TRUE_LAYER_ENABLE_MOCK` to `"true"`.

## Troubleshooting

Refer to the specific [README](./docs/troubleshooting.md)
