# VCR Recording and Rerecording
Occassionally it is important to update VCR cassettes. This ensures that tests
which rely on external service stubs from VCR are not returning false positives.

## Setup

### Benefits checker
 - ensure `.env.test` has the following benefit checker details pointing to staging - see `values-staging.yaml`

  ```
  BC_LSC_SERVICE_NAME=
  BC_CLIENT_ORG_ID=
  BC_CLIENT_USER_ID=
  BC_WSDL_URL=
  BC_USE_DEV_MOCK=false
  ```

 - ensure you switch `BC_USE_DEV_MOCK=false` when recording. You can switch `BC_USE_DEV_MOCK=true` after recording or leave to use staging.

### Provider manager issues
  - connect to VPN
  - set PROVIDER_DETAILS_URL
  - ensure Rails.configuration.x.provider_details points to staging for the test
  - check staging actually works (it has not in the past)

## Address lookup
  - ensure `.env.test` has `ORDNANCE_SURVEY_API_KEY` set

## Legal Framework API
  - ensure `.env.test` has `LEGAL_FRAMEWORK_API_HOST` pointing to staging environment

## Rerun test suite

You can rerun the entire test suite but it may be preferable to add
and commit specs and feature cassettes separately.

To rerecord all cassettes by appending [not recommended] you can use:
```sh
VCR_RECORD_MODE=all bundle exec rake
```

To recreate all cassettes [recommended] you can use:
```sh
rm -rf spec/cassettes/ features/cassettes/
bundle exec rake
```
*Note: because you have deleted the cassettes the default recording mode of `:once` means it will rerecord*

### Rerecord spec cassettes only

```sh
rm -rf spec/cassettes/
bundle exec rspec -fp
```

### Rerecord feature cassettes only

```sh
rm -rf features/cassettes/
bundle exec cucumber
```
