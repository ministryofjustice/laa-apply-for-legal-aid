# LAA Apply for legal aid

PENTEST VERSION

This is the service api for persisting application related information to the back end database and
may well be used to fire requests to other services.

[![CircleCI](https://circleci.com/gh/ministryofjustice/laa-apply-for-legal-aid/tree/master.svg?style=svg)](https://circleci.com/gh/ministryofjustice/laa-apply-for-legal-aid/tree/master)

* Ruby version
    * Ruby version 2.6.3
    * Rails 6

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
This requires your gpg key to have been added to git-crypt.  Liaise with another developer to action the steps in [git-crypt.md](docs/git-crypt.md)

Once the pull request has been merged, re-pull master and run 

```
git-crypt unlock
```
Update the `.env.sample` file, to get the tests running you will need to obtain and set values for the following:
```bash
GOVUK_NOTIFY_API_KEY=
CHECK_FINANCIAL_ELIGIBILITY_HOST=
```

To get the app in a usable state you will need to provide an admin password before running set up as seeding the admin user requires this value
```bash
ADMIN_PASSWORD=
```

From the root of the project execute the following command:
```
bin/setup
```

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

#### Guard

The repo also includes a Guardfile, this can be run in a terminal window
```sh
bundle exec guard
```

When changes to test files are made it will run the tests in that file
When changes are made to objects are made it will attempt to pattern match the appropriate tests and run them, e.g. changes to `app/models/applicant.rb` will run `spec/models/applicant_sepc.rb`
Ensuring your test files match the folder structure and naming convention will help guard monitor your file changes 
**Note**: Guard will not currently run cucumber features, there is an open Issue on the `guard-cucumber` repo
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
[guide](https://user-guide.cloud-platform.service.justice.gov.uk/tasks.html#git-crypt).

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

#### Live

Authentication is made to the LAA portal, which sends back a packet of data like this:

```
{
  "USER_EMAIL"=>[“a.user@example.com”],
  "LAA_APP_ROLES"=>["CWA_XXLSC_EM_ACT_REP,EMI,CCMS_Apply"],
  "LAA_ACCOUNTS"=>[“9X999X”]
}
```

These are translated by the devise_saml_authenticatable module to the appropriate fields on the provider using the mapping specified in `config/attribute-map.yml`.

#### Development

User login on dev can be mocked out by adding the the following settings

```
LAA_PORTAL_IDP_SSO_TARGET_URL=http://localhost:3002/saml/auth
LAA_PORTAL_MOCK_SAML=true
```

This will enable you to login as a provider with the usernames specified in `config/initializers/mock_saml.rb`.
Not that the provider firm_id is the same for `firm1-user1` and `firm1-user2`; all other users will belong to
different firms.  The password for all users is `password`.


### Post-authentication provider details retrieval
Once the provider has been authenticated, either by the portal or by the mock-saml mechanism described above,
an after_action method `#update_provider_details` on the `SamlSsessionsController` is executed. This will call 
the `update_details` method on the current_provider (a Provider object supplied by Devise) whch generates
a background job to query the 
provider details API and updates any details that have changed on the provider record.

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

This mock data allows for testing with more meaningful bank transactions, including benefits data tagged with correct DWP codes. To ensure that this benefits data is correctly analysed, so it can be processed successfully by CFE, an applicant with the National Insurance Number `AA123456A` must be used.

## Admin Portal

The admin portal is at `/admin`. To access it, there must be an `AdminUser` defined.

If `ENV['ADMIN_PASSWORD']` returns a password, running `rake db:seed` will create an
admin user with username `apply_maintenance`, and that password.

To allow reset mode within the admin portal, `ENV['ADMIN_ALLOW_RESET']` must return "true"

The non-passported user journey is turned off in production. It can be toggled in
Staging and UAT at `/admin/settings`

To test the non-passported user journey, the
`ENV['ALLOW_NON_PASSPORTED_ROUTE']` must return "true". This is only available in the
Staging and UAT environments.

To allow the creation of test applications at different stages, for each provider,
`ENV['ADMIN_ALLOW_CREATE_TEST_APPLICATIONS']` must return "true". This is only available in the
Staging and UAT environments.

## Monitoring & Debugging

- To monitor the worker jobs execution you can access `/sidekiq`:
    - User: `sidekiq`
    - Password: `worker: webUiPassword` in the secrets.
- To access to the Site Administration Dashboard you need to point to `/support`.
  Credentials are the same as in the Admin Portal.

- To monitor Slack alerts from our service:
  - [UAT](https://mojdt.slack.com/messages/GGW4FCZBL)
  - [Staging](https://mojdt.slack.com/messages/GGWMW7M0F)
  - [Production](https://mojdt.slack.com/messages/GGWE9V9BP)

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

###Backups###

Backups are taken daily at 5:40am and stored for 7 days, these are automated backups and cannot be deleted. The retention date can be changed.

A CronJOB takes hourly snapshots of production between 6am and 9pm. These need to be periodically deleted as a maximum of 100 can be stored. At present all but the most recent 32 manual snapshots (approx 2 days of hourly backups) are deleted every 4 days.

## 3rd party integrations

### True Layer

To connect the True Layer API, a client ID and client SECRET must be supplied. They can be
set via the environment variables `TRUE_LAYER_CLIENT_ID` and `TRUE_LAYER_CLIENT_SECRET`
respectively. Visit https://console.truelayer.com to get a client ID and client SECRET.

True Layer offer a Mock Bank option (see https://docs.truelayer.com/#mock-users). To enable
this functionality, set the environment variable `TRUE_LAYER_ENABLE_MOCK` to `"true"`.


## Check Financial Eligibility Service

The URL for this service should be set using the environment variable `CHECK_FINANCIAL_ELIGIBILITY_HOST`

---

## Geckoboard Dashboard

Several sets of statistics are exported to Geckoboard for displaying on an application dashboard.

### How to add a new widget to the dashboard

There are three steps to creating a new widget for the Geckoboard dashboard

### 1. Create a widget data provider

Create a new class in the `app/models/dashboard/widget_data_providers` directory. This should define three class methods:

* `.handle` - the name of the widget, which will be qualified with a project name and environment.  For example `my_widget` would become `apply_for_legal_aid.production.my_widget` in the list of datasets on Geckoboard
* `.dataset_defintion` - the list of fields that will be in the dataset (see https://developer.geckoboard.com/hc/en-us/sections/360002865451-Getting-started for details on how to define and provide data for a dataset.)
* `.data` - the actual data that will be sent to Geckoboard every time it is run.

This data provider will be used by the `Dashboard::Widget` class when called with the name of the data provider as a parameter.

### 2. Add a cronjob to run it

Create a yaml configuration file for each cronjob under `app/helm_deploy/apply_for_legal_aid/templates` by copying the `.dashboard_template_cron.yaml.sample` file and configure it to run the command `rake job:dashboard:update[the WidgetDataProvider class name here]` with
your chosen cron job schedule.

### 3. Add the widget to the Geckoboard dashboard

Once the job has been run at least once, you will be able to select the dataset as a data source when adding a new widget.

----



## Troubleshooting

Refer to the specific [README](./docs/troubleshooting.md)
