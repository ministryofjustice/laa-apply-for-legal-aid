# LAA Apply for legal aid

This is the service api for persisting application related information to the back end database and
may well be used to fire requests to other services.

[![CircleCI](https://circleci.com/gh/ministryofjustice/laa-apply-for-legal-aid/tree/master.svg?style=svg)](https://circleci.com/gh/ministryofjustice/laa-apply-for-legal-aid/tree/master)

* Ruby version
    * Ruby version 2.6.3
    * Rails 5

* System dependencies
    * postgres 10.5
    * redis
    * yarn
    * wkhtmltopdf

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

### Malware check of uploaded files

ClamAV is used to make sure uploaded files do not contain any malware.
If you are on Mac, ClamAV would have been installed by running `bin/setup`

On Ubuntu you can install it with:
```
sudo apt-get install clamav clamav-daemon -y
sudo freshclam
sudo /etc/init.d/clamav-daemon start
```

You may also need to run:
```
sudo apt install clamdscan
```

### Run the application server

```
bin/rails s
```

NOTE: You also need to start sidekiq in another terminal window:

```
bundle exec sidekiq
```

You can also use foreman to start the application server and sidekiq with one command

```
gem install foreman
foreman start -f Procfile
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

### Accessibility testing with webhint

webhint (https://webhint.io/) is used to check if pages are accessible.

Run `rake webhint:generate_reports`. This will

- delete any existing files from previous runs
- execute `SAVE_PAGES=true bin/rails cucumber` to run the feature tests and save all pages to `tmp/webhint_inputs`
- and the execute `./bin/generate_webhint_reports.sh` to check those pages with webhint.

The result will be printed as a JSON result and you can also find HTML reports in the `hint-report` folder.

## Deployment

The deployment is triggered on all builds in [CircleCI](https://circleci.com/gh/ministryofjustice/laa-apply-for-legal-aid) but requires approval to the desired environment.

**NOTE:** **git-crypt** is required to store secrets required for **uat**, **staging** and **production** environments.
To be able to modify those secrets, **git-crypt** needs to be set up according to the following
[guide](https://ministryofjustice.github.io/cloud-platform-user-docs/03-other-topics/001-git-crypt-setup/#git-crypt).

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

## Dev: running locally

### LAA Portal Authentication dev setup

Add the following to .env.development
```
LAA_PORTAL_IDP_SSO_TARGET_URL=https://portal.tst.legalservices.gov.uk/oamfed/idp/samlv20
LAA_PORTAL_IDP_CERT=< LAA_PORTAL_IDP_CERT (dev)>
LAA_PORTAL_CERTIFICATE=< LAA_PORTAL_CERTIFICATE (dev)>
LAA_PORTAL_SECRET_KEY=< LAA_PORTAL_SECRET_KEY(dev)>
LAA_PORTAL_MOCK_SAML=false
```
** Note the above keys can be found in LastPass

### Authentication

Mock Saml request on dev add the the following settings

```
LAA_PORTAL_IDP_SSO_TARGET_URL=http://localhost:3002/saml/auth
LAA_PORTAL_MOCK_SAML=true
```

### Benefits checker

To mock the benefits check in development and testing add the following environment
variable:

```
BC_USE_DEV_MOCK=true
```

This will enable `MockBenefitCheckService`. See `MockBenefitCheckService::KNOWN for
credentials that will return 'Yes' for has qualifying benefits.

## Admin Portal

The admin portal is at `/admin`. To access it, there must be an `AdminUser` defined.

If `ENV['ADMIN_PASSWORD']` returns a password, running `rake db:seed` will create an
admin user with username `apply_maintenance`, and that password.

To allow reset mode within the admin portal, `ENV['ADMIN_ALLOW_RESET']` must return "true"

## Databases

### Staging and Production

Staging and production databases are RDS instances on the MOJ Cloud Platform. Connection details are held in LastPass.

These databases are within the AWS VPC and are not publicly available. In order to connect
to an RDS database from a local client, first run:

`kubectl -n laa-apply-for-legalaid-staging port-forward port-forward-rds 5433:80`

This will then allow you to connect to the database, eg:

`psql --host=localhost --port=5433 --username=<username> --password --dbname=apply_for_legal_aid_staging`

- Change `staging` to `production` in the above commands to access production.
- Port 5433 is used in the above examples instead of the usual 5432 for postgres, as 5432 will not work if postgres is running locally.

## 3rd party integrations

### True Layer

To connect the True Layer API, a client ID and client SECRET must be supplied. They can be
set via the environment variables `TRUE_LAYER_CLIENT_ID` and `TRUE_LAYER_CLIENT_SECRET`
respectively. Visit https://console.truelayer.com to get a client ID and client SECRET.

True Layer offer a Mock Bank option (see https://docs.truelayer.com/#mock-users). To enable
this functionality, set the environment variable `TRUE_LAYER_ENABLE_MOCK` to `"true"`.

## Troubleshooting

Refer to the specific [README](./docs/troubleshooting.md)
