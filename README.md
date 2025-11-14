

[![CircleCI](https://circleci.com/gh/ministryofjustice/laa-apply-for-legal-aid.svg?style=shield)](https://circleci.com/gh/ministryofjustice/laa-apply-for-legal-aid/tree/main)
[![Ministry of Justice Repository Compliance Badge](https://github-community.service.justice.gov.uk/repository-standards/api/laa-apply-for-legal-aid/badge)](https://github-community.service.justice.gov.uk/repository-standards/laa-apply-for-legal-aid)

# LAA Apply for civil legal aid

Sara was here
The laa-apply-for-legal-aid system is a web service for solicitors that provide legal aid services. The service enables users to submit applications for legal aid on-line.

## Table of Contents
- [**Architecture Diagram**](#architecture-diagram)
- [**Environment mappings**](docs/environment_mappings.md)
- [**Documentation for developers**](#documentation-for-developers)
- [**Dependencies**](#dependencies)
- [**Initial setup**](#initial-setup)
- [**Deployment**](#deployment)
    - [UAT Deployments](#uat-deployments)
- [**Dev: running locally**](#dev-running-locally)
    - [LAA Portal Authentication dev setup](#laa-portal-authentication-dev-setup)
    - [Authentication](#authentication)
        - [Live](#live)
        - [Development](#development)
    - [Post-authentication provider details retrieval](#post-authentication-provider-details-retrieval)
    - [Signing out of the application](#signing-out-of-the-application)
    - [How to set up localhost to use the portal](#how-to-set-up-localhost-to-use-the-portal)
    - [Benefits checker](#benefits-checker)
    - [Mock TrueLayer Data](#mock-trueLayer-data)
- [**Admin Portal**](#admin-portal)
- [**Monitoring & Debugging**](#monitoring--debugging)
- [**Databases**](#databases)
    - [Staging and Production](#staging-and-production)
- [**3rd party integrations**](#3rd-party-integrations)
    - [True Layer](#true-layer)
- [**Check Financial Eligibility Service**](#check-financial-eligibility-service)
- [**Legal Framework API Service**](#legal-framework-api-service)
- [**Troubleshooting**](#troubleshooting)
- [**Maintenance mode**](#docs/maintenance_mode.md)
- [**ClamAV setup and implementation**](#malware-check-of-uploaded-files)


## Architecture Diagram

View the [architecture diagram](https://structurizr.com/share/55246/diagrams#apply-container) for this project.
It's defined as code and [can be edited](https://github.com/ministryofjustice/laa-architecture-as-code/blob/main/src/main/kotlin/model/Apply.kt) by anyone.

## Documentation for developers.

Documentation of certain parts of the system which are particularly complex can be found [here](https://dsdmoj.atlassian.net/wiki/spaces/ATPPB/pages/3020752222/Application+Development+Documentation)
* [GOVUK Notify and sending emails from Apply](https://dsdmoj.atlassian.net/wiki/spaces/ATPPB/pages/3028877542/Sending+emails+from+Apply)
* [ProceedingType Full Text search](https://dsdmoj.atlassian.net/wiki/spaces/ATPPB/pages/3028811988/Proceeding+Type+Full+Text+Search)
* [Legal Framework model associations](https://dsdmoj.atlassian.net/wiki/spaces/ATPPB/pages/3024847884/Legal+Framework+model+associations)

## Dependencies

* Ruby version
    * Ruby version 3.x
    * Rails 7.0.x

* System dependencies
    * postgres
    * redis
    * yarn
    * libreoffice
    * clamav

Install dependencies with homebrew:
```
brew bundle
```

## Initial setup

1. Copy the `.env.sample` file and name the new file `.env.development`

1. To install OS dependencies (MacOSX only):
    ```
    brew bundle
    ```

    You may need to switch postgres versions to match version used by app
    ```
    brew services list
    ...
    brew services stop postgresql@XX
    brew services start postgresql@14
    ```

1. From the root of the project execute the following command:
    ```
    [bin/spring stop] *
    bin/setup
    ```
    \* possibly needed if spring started and errors encountered when running a command like `rails db:migrate:status`

1. Once setup, you can run the dev binstub to run the server, sidekiq, and watch
for JS and CSS changes.

    ```
    bin/dev
    ```

### Malware check of uploaded files

ClamAV (anti-virus) is used to make sure uploaded files do not contain any malware.

see [docs/clamav.md](./docs/clamav.md) for setup and details.

### Overcommit

Overcommit is a gem which adds git pre-commit hooks to your project. Pre-commit hooks run various
lint checks before making a commit. Checks are configured on a project-wide basis in .overcommit.yml.

To install the git hooks locally, run `overcommit --install`. If you don't want the git hooks installed, just don't run this command.

Once the hooks are installed, if you need to you can skip them with the `-n` flag: `git commit -n`

### Run the application server

```
bin/rails s
```

NOTE: You also need to start sidekiq and redis in separate terminal windows:

```
bundle exec sidekiq
```

```
redis-server
```

You can also use foreman to start the application server, sidekiq and redis with one command:

```
gem install foreman
foreman start -f Procfile
```

### Running tests

Ensure you have an `.env.test` file. This can be the same as your .env.development file. In addition you should set the following.

Set `BC_USE_DEV_MOCK=true` to mock the call to the benefits checker.
Set `LEGAL_FRAMEWORK_API_HOST=<staging api>`
Set `CFE_CIVIL_HOST=<staging api>`
Set `HMRC_API_HOST=<staging api>`

Runs Rubocop, RSpec specs and Cucumber features

```sh
bin/rake
```

#### VCR cassettes

VCR is used to record interactions with external services and play back these stubs during test runs. To ensure the recorded cassettes used in the specs and features are up to date you should occasionally rerecord them.

see [VCR Recording](docs/vcr_recording.md) for setup and recommended approaches to rerecording of cassettes.

#### Puffing-billy stubs (and request cache)

[Puffing-billy](https://github.com/oesmith/puffing-billy) is used to stub (or record) external service calls made from javascript.

see [Puffing-billy recording](docs/puffing_billy_recording.md) for setup and recommended approaches to creating new stubs or recording requests in a persisted cache.

#### Guard

The repo also includes a Guardfile, this can be run in a terminal window
```sh
bundle exec guard
```

When changes to test files are made it will run the tests in that file
When changes are made to objects it will attempt to pattern match the appropriate tests and run them, e.g. changes to `app/models/applicant.rb` will run `spec/models/applicant_spec.rb`
Ensuring your test files match the folder structure and naming convention will help guard monitor your file changes

#### pry-rescue

The repo also includes `pry-rescue`, a gem to allow faster debugging. Running
```
bundle exec rescue rspec
```
will cause any failing tests or unhandled exceptions to automatically open a `pry` prompt for immediate investigation.

## Deployment

The deployment is triggered on all builds in [CircleCI](https://circleci.com/gh/ministryofjustice/laa-apply-for-legal-aid) but requires approval to the desired environment.

A build is only triggered by Circle CI when a pull request is opened in GitHub, this also applies to `Draft` pull requests.

* For more information on howto setup **Helm** in your local environment refer to the following [guide](https://ministryofjustice.github.io/cloud-platform-user-docs/02-deploying-an-app/002-app-deploy-helm/#installing-and-configuring-helm-and-tiller).
* For more deployment information refer to the specific [README](./helm_deploy/apply-for-legal-aid/README.md)

### UAT Deployments

UAT deployments are automatically created and deleted as part of the Circle CI process. Once a pull request has been created on GitHub, Circle CI will create a deployment under the new branch name.
Once the branch has been merged with `main` the UAT deployment is deleted as part of the Circle CI process to deploy production.

In some cases a deployed branch will not be merged with `main` in which case the following commands can be used to manually delete the UAT deployment:

```
# list the availables releases:
helm list --namespace=laa-apply-for-legalaid-uat --debug --all

# delete a specific release
helm delete --namespace=laa-apply-for-legalaid-uat <name-of-the-release>
```

## Dev: running locally
### Authentication

#### Live (TO REDO)

Authentication is made to the EntraID external tenant (a.k.a SiLAS), which sends back a packet of data similar to that seen in the `mock_auth` return value in `app/lib/omni_auth/strategies/silas.rb`. This is used to find or create the user, along with associated office codes/LAA account numbers (Active record `Office` associations are created later however - see PDA retrieval).

#### Development

User login on dev can be turned on by adding the following settings to your `.env.development`

```shell
OMNIAUTH_ENTRAID_MOCK_AUTH_ENABLED=true
OMNIAUTH_ENTRAID_MOCK_USERNAME="martin.ronan@example.com"
OMNIAUTH_ENTRAID_MOCK_PASSWORD="set-me-to-whatever"
```

This will direct you to provide a username/email and password to login as that user. The user will have specific mocked responses from EntraID (SiLAS) (see `app/lib/omni_auth/strategies/silas.rb`) and the Provider Data API (see `app/services/pda/mock_provider_details.rb`).

> [!NOTE]
> On UAT you can also enable this mock behaviour and use the password available in the AWS secrets manager/Kubernetes secret to
> login.

### Selected office's provider data retrieval
Once the provider has been authenticated, either by EntraID/SiLAS or by mock_auth, mentioned above,
a "Select the account number..." page is shown. Selecting an account number (a.k.a office code) and continuing will
call the "Provide data API" (PDA) for the selected office and user. This will be mocked in
a background job to query the provider details API and updates any details that have changed on the provider record.~~


### Signing out of the application (TO REDO)

When using the mock auth in development or on UAT, sign out works in the way you'd expect, destroying the session: Clicking signout takes you to a page confirming you're signed out, and going to the start url will redirect you to the sign-in page.

TODO: Once the flow for signout is confirmed
~~When using the portal for authentication, (on staging or live, or if configured as described below, on localhost), the
sign out link takes you to a feedback page, but doesn't really sign you out.  This is a side effect of using the
portal Single Sign On system. You're not signed out until you tell the portal you've signed out, and when you do that,
you are signed out of all other applications at the same time. (Behind the scenes, the Devise `authenticate_provider!`
method contacts the portal to see if your signed in, and if so, repopulates the session with the required data).~~

~~You can sign out of the portal by going to https://portal.stg.legalservices.gov.uk/oam/server/logout~~

### How to set up localhost to use the EntraId

To run the app locally using Azure EntraID for authentication you will need to run the rails server over TLS. This is because any redirect URI setup for the local host in the App registration is using `https` for security reasons.

### Setup localhost to use self-signed certificate for TLS

see [rails development using self-signed certificate](https://madeintandem.com/blog/rails-local-development-https-using-self-signed-ssl-certificate/)

```sh
# create dir to store them, anywhere
mkdir ~/.ssl/

# generate self-signed cert and key, output to the dir created
# you will be asked a load of questions but can leave them blank
openssl req -x509 -sha256 -nodes -newkey rsa:2048 -days 365 -keyout ~/.ssl/localhost.key -out ~/.ssl/localhost.crt

# run rails server using the self-signed certificate
rails s -b "ssl://localhost:3000?key=$HOME/.ssl/localhost.key&cert=$HOME/.ssl/localhost.crt"
```
note: running `bin/setup` will give you the option to generate this certificate via its script.

You can now open `https://localhost:3000` and login. Your browser will probably issue a warning about certificates and prevent you from continuing. For chrome you can select choose to navigate to the site anyway via an "Advanced options" link or similar.


### Benefits checker

To mock the benefits check in development and testing add the following environment
variable:

```
BC_USE_DEV_MOCK=true
```

This will enable `MockBenefitCheckService`. See `MockBenefitCheckService::KNOWN for
credentials that will return 'Yes' for has qualifying benefits.

This environment variable should be set to ```false``` when recording new vcr cassettes otherwise the test will pass locally and fail on CircleCI.

### Mock TrueLayer Data

TrueLayer test data can be replaced by mock data from db/sample_data/bank_transactions.csv. This can be toggled in the Admin Portal at `/admin/settings`.

This mock data allows for testing with more meaningful bank transactions, including benefits data tagged with correct DWP codes.

## Admin Portal

The admin portal is at `/admin`. To access it in UAT, there must be an `AdminUser` defined.

Running `rake db:seed` will create an admin user with username `apply_maintenance` in all UAT deployments.

The admin portal is only accessible in Staging and Production using Google login for authorised accounts.

To allow reset mode within the admin portal, `ENV['ADMIN_ALLOW_RESET']` must return "true"

To allow the creation of test applications at different stages, for each provider,
`ENV['ADMIN_ALLOW_CREATE_TEST_APPLICATIONS']` must return "true". This is only available in the
Staging and UAT environments.

## Monitoring & Debugging

- To monitor the worker jobs execution you can access `/sidekiq`:
    - User: `sidekiq`
    - Password: see `worker: webUiPassword` in the secrets (or `SIDEKIQ_WEB_UI_PASSWORD` env var)

- To monitor Slack alerts from our service:
    - [UAT](https://mojdt.slack.com/messages/GGW4FCZBL)
    - [Staging](https://mojdt.slack.com/messages/GGWMW7M0F)
    - [Production](https://mojdt.slack.com/messages/GGWE9V9BP)

## Logging

To enable full logs in the test environment, `ENV['RAILS_ENABLE_TEST_LOG']` must return "true".

`ENV['RAILS_ENABLE_TEST_LOG']` defaults to nil (falsey) in order to reduce log pollution during testing.

## Databases

### Staging and Production

Staging and production databases are RDS instances on the MOJ Cloud Platform. Connection details are held in 1Password.

These databases are within the AWS VPC and are not publicly available. In order to connect
to an RDS database from a local client, first run:

`kubectl -n laa-apply-for-legalaid-staging port-forward port-forward-rds 5433:80`

This will then allow you to connect to the database, eg:

`psql --host=localhost --port=5433 --username=<username> --password --dbname=apply_for_legal_aid_staging`

- Change `staging` to `production` in the above commands to access production.
- Port 5433 is used in the above examples instead of the usual 5432 for postgres, as 5432 will not work if postgres

### Backups

Backups are taken daily at 5:40am and stored for 7 days, these are automated backups and cannot be deleted. The retention date can be changed.

## Anonymised database export and local restore

In order to create an anonymised dump of an environments database you can:

```bash
$ ./scripts/db_export.sh [environment]
```
Where environment is `production`, `staging` or a branch name from uat, e.g. `ap-1234`

It requires that you have kubectl authenticated and your context set to the current live context

It will connect to the required kubernetes namespace and pod and run the `rake db:export` task this will generate a filename of `[environment].anon.sql`

It will then copy the compressed restore file to the `tmp` folder in the project and de-compress it

If a file from the same environment exists, it will prompt you to overwrite the local copy

It will then output a restore command to enable you to restore it to your local psql instance at your convenience

A typical output for uat should resemble:
```
Finding pod for uat
Connecting to apply-ap-1234-apply-for-legal-aid-1234567890abc, anonymizing, compressing and exporting DB
Success
You can restore this locally by running:
 psql -q -P pager=off -d apply_for_legal_aid_dev -f ./tmp/uat.anon.sql
```
## Anonymised database restore to UAT

To apply the anonymised database export to a UAT branch you can run the restore script:

```bash
$ ./scripts/restore_anonymised_db.sh [branch-name]
```
Where branch name is either the full git branch name or just the start of it e.g `ap-2555-anon-uat-db` or `ap-2555`

It requires that you have kubectl authenticated and your context set to the `live` cluster. The `db_export.sh script` will save
the anonymised database to your local `/tmp` folder. This script will copy the file to the `/tmp` folder on the selected UAT instance,
drop the existing database and restore using the anonymised data.

The script will also output the anonymised email addresses for 10 Providers. These can be used to login to the UAT instance.
## 3rd party integrations

### True Layer

To connect the True Layer API, a client ID and client SECRET must be supplied. They can be
set via the environment variables `TRUE_LAYER_CLIENT_ID` and `TRUE_LAYER_CLIENT_SECRET`
respectively. Visit https://console.truelayer.com to get a client ID and client SECRET.

True Layer offer a Mock Bank option (see https://docs.truelayer.com/#mock-users). To enable
this functionality, set the environment variable `TRUE_LAYER_ENABLE_MOCK` to `"true"`.


## Check Financial Eligibility Service

The URL for this service should be set using the environment variable `CFE_CIVIL_HOST`.

## Legal Framework API Service

The URL for this service should be set using the environment variable `LEGAL_FRAMEWORK_API_HOST`.

## Troubleshooting

Refer to the specific [README](./docs/troubleshooting.md)
