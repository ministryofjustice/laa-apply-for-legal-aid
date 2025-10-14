# Puffing-billy stub creating and request cache

Some feature tests exercise application logic that includes asynchronous javascript
calls to external services (APIs). In particular, searching for proceedings and organisations is achieved through ajax calls to the legal-framework-api. VCR does not intercept browser calls therefore puffing-billy is used. This provides a "rewriting web proxy" to intercept and stub the calls.

VCR and puffing-billy can be used together to achieve stubbing of any calls to external services from the backend and frontend respectively.

## Setup

### Legal Framework API
This service is explicitly called from javascript to search for proceedings and organisations. Therefore we must ensure `.env.test` has `LEGAL_FRAMEWORK_API_HOST` pointing to staging environment.

## Stubbing
While it is possible to record and playback requests, using puffing-billy, in a manner similar to vcr, stubbing a request is the preferred option. To add a stub you should add or extend helper methods in the `features/support/puffing_billy_helper.rb` and then call that in a cucumber step definition that will make the call you wish to stub.

> [!NOTE]
> We force binary encoding - `.force_encoding("BINARY")` - to ensure response JSON containing problematic characters suchs a braces - `(`, `)` - do not cause issues, as they have done in the past. This emulates what puffing-billy does when recording requests.


```ruby
# features/support/puffing_billy_helper.rb
def stub_my_call
  proxy
    .stub("https://legal-framework-api-staging.cloud-platform.service.justice.gov.uk:443/proceeding_types/searches", method: "post")
    .and_return(
      headers: {
        "Access-Control-Allow-Origin" => "*",
      },
      code: 200,
      body: { key: "value", another_key: "another_value" }.to_json.force_encoding("BINARY"),
    )
end
```

And use

```ruby
When("I do something that calls a service via ajax") do
  stub_my_call

  fill_in("some-input-that-makes-ajax-call", with: 'whatever')
end
```

## Request caching (recording)

If you want to record a request and response, either to use in a feature test or to use to create a stub (before deleting it), you can:

1. comment out/remove any proxy.stubs already in use by the feature

2. amend the puffing-billy config in `features/support/puffing_billy.rb`
    - set `non_whitelisted_requests_disabled = false`
    - ensure `cache = true` and `persist_cache = true`
    - set `record_requests` = true (optional as the DEBUG|DEBUG_BILLY commandline setting will set to true anyway)
    - set `certs_path = "features/puffing-billy/request_certs"` *1

*1
> [!WARNING]
> Do NOT commit `features/puffing-billy/request_certs` dir or its content to repo. It may contain private RSA keys. They have been git ignored but you should check you commits before pushing nonetheless. In addition, check the contents of any new or amended request_cache directory files for secrets before committing them.

3. run the feature (with debug to view request being made of billy's proxy)

  ```shell
  DEBUG_BILLY=true cucumber features/providers/applicant_details.feature:3
  ```

4. The requests should appear in the configured folder
   `features/puffing-billy/request_cache`

5. Check the new or amended request_cache files for secret leaks.

Example
```ruby
# features/support/puffing_billy.rb
Billy.configure do |c|
  ...
  c.cache = true
  c.persist_cache = true
  c.non_whitelisted_requests_disabled = false
  c.certs_path = "features/puffing-billy/request_certs"
  c.record_requests = true
  ...
end
```

To rerecord a request cache simply delete the file and rerun the feature.

## Debugging

You can display all calls that puffing-billy proxied using an env var as below.

```shell
DEBUG_BILLY=true cucumber features/providers/applicant_details.feature:3
```
