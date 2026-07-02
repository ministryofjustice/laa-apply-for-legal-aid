# Pact - consumer driven testing

## References
- [Pact version 2 readme](https://docs.pact.io/implementation_guides/ruby/readme_v2)
- [Pact specification versions](https://docs.pact.io/implementation_guides/pact_specification#specification-documentation)
- [Pact specification repo](https://github.com/pact-foundation/pact-specification)

- [Pact broker repo](https://github.com/ministryofjustice/laa-data-pact-broker)
- [Pact brocker host](https://laa-data-pact-broker.apps.live.cloud-platform.service.justice.gov.uk/)
- [Pact broker webhooks](https://laa-data-pact-broker.apps.live.cloud-platform.service.justice.gov.uk/hal-browser/browser.html#https://laa-data-pact-broker.apps.live.cloud-platform.service.justice.gov.uk/webhooks)
- [Pact webhook service verification](https://github.com/apps/laa-java-service-deployer/installations/44250102)

## What is pact
Pact provides a standard convention base specification for writing and using contract tests. We use consumer
driven contract testing where the consumer, typically civil apply, defines how they expect to consume a
provider's (APIs such as legal-framework-api and laa-data-access-api) endpoints.

The high-level flow pact base flow

- The consumer generates a contract or contracts
- The consumer publishes the contract(s) to a broker/middleman
- The provider or providers retrieve the contract(s) from the broker
- The provider(s) verify the contract(s)

### Pipeline integration
The pact integration is achieved in the pipeline via the `pact.yml` github action, which triggers the following actions

Consumer publishes pact
        │
        ▼
Pact Broker webhook triggered
        │
        ▼
Starts provider workflow
        │
        ▼
Provider publishes verification
        │
        ▼
Consumer runs can-i-deploy repeatedly until provider verification is success, failure or timeout.

When the consumer (this repo) has a PR opened against it on github the `pact.yml` github action will generate and publish a contract to [the pact brocker](https://laa-data-pact-broker.apps.live.cloud-platform.service.justice.gov.uk/). It will specify the "consumer version" using the github sha of the last commit.

To achieve the publishing of the consumer contract to the pact broker the github action has been provided with 3 secrets. These are set in Github > Settings > Secrets and variables > Actions. The secrets values are available from the teams password manager.

```sh
PACT_BROKER_BASE_URL
PACT_BROKER_USERNAME
PACT_BROKER_PASSWORD
```

The publishing of the contract triggers a any configured provider webhooks in the pact broker. These then verify these contracts by calling the `can-i-deploy` method of the pact-broker binary. Since it may take some time to complete the `can-i-deploy` call it is called recursively until success, failure or timeout.

## Local testing

### Local testing without a broker
You can generate the pact contract locally by running the following. Note that this will run all pacts and place them ALL in the applicable consumer-provider-pair json file under `spec/pacts` (or whichever directory is configured by the spec, see `pact_dir` `opt`). *These generated pacts are .gitignore'd because they are expected to be generated afresh for publication on CI.*

#### Generate the pact
```sh
bundle exec rails pact:consumer:generate
```

You can run individual pact specs using the tag `pact`

```sh
bundle exec rspec -t pact spec/pact/providers/legal_framework_api/countries/all_spec.rb
```

#### Copy pact to provider repo locally and verify
Once you have the consumer pact contract you can copy the file to the configured location in the provider. See the providers own
documentation and/or configuration for setting up the verification of the manually copied pact.

### Local testing with a broker
If there is a broker available to which the consumer has been granted the relevant privileges (see our [pact broker](https://github.com/ministryofjustice/laa-data-pact-broker)) then you can publish the pacts from your local machine.

To publish from your local machine you will need to supply the following credentials. These secrets are available in the teams password manager.

```sh
PACT_BROKER_BASE_URL=<see-password-manager>
PACT_BROKER_USERNAME=<see-password-manager>
PACT_BROKER_PASSWORD=<see-password-manager>
```

Place these in the `.env.development` (or `.env`) then run:

```sh
bundle exec rails pact:consumer:publish
```
