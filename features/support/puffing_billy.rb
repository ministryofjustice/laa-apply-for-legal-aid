require "billy/capybara/cucumber"
require "table_print"

Billy.configure do |c|
  c.cache = true
  # c.cache_request_headers = false
  # c.ignore_params = [],
  # c.path_blacklist = []
  # c.merge_cached_responses_whitelist = []
  c.persist_cache = true
  # c.ignore_cache_port = true
  # c.non_successful_cache_disabled = false
  # c.non_successful_error_level = :warn
  c.non_whitelisted_requests_disabled = true # turn off all unrecorded/uncached requests
  # c.cache_whitelist = ["https://legal-framework-api-staging.cloud-platform.service.justice.gov.uk"]
  c.cache_path = "features/puffing-billy/request_cache"
  # c.certs_path = 'features/puffing-billy/request_certs'
  # c.proxy_host = 'example.com' # defaults to localhost
  # c.proxy_port = 12345 # defaults to random
  # c.proxied_request_host = nil
  # c.proxied_request_port = 80
  c.record_requests = true # defaults to false
  c.cache_request_body_methods = %w[post patch put] # defaults to ['post']
end

Before("@billy") do
  Capybara.current_driver = if ENV["BROWSER"] == "chrome"
                              :selenium_chrome_billy
                            else
                              :selenium_chrome_headless_billy
                            end

  proxy.stub(/content-autofill\.googleapis\.com/).and_return(code: 200, body: "")

  proxy
  .stub(%r{legal-framework-api-staging.cloud-platform.service.justice.gov.uk.*/organisation_searches}, method: "options")
  .and_return(
    headers: {
      "Access-Control-Allow-Origin" => "*",
      "Access-Control-Allow-Headers" => "Content-Type",
    },
    code: 200,
  )
end

After("@billy") do
  Capybara.use_default_driver

  puts "Requests received via Puffing Billy Proxy:"

  puts TablePrint::Printer.table_print(Billy.proxy.requests, [
    :status,
    :handler,
    :method,
    { url: { width: 100 } },
    :headers,
    :body,
  ])
end
