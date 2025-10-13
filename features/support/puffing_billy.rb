require "billy/capybara/cucumber"

# if you want to record a request and response in order to generate a stub you can
# 1. comment out/remove any proxy.stubs in use
# 2. set non_whitelisted_requests_disabled = false (see below)
# 3. ensure cache = true and persist_cache = true
#
Billy.configure do |c|
  c.cache = true
  c.cache_request_headers = false
  # c.ignore_params = [],
  # c.path_blacklist = []
  # c.merge_cached_responses_whitelist = []
  c.persist_cache = true
  # c.ignore_cache_port = true
  # c.non_successful_cache_disabled = false
  # c.non_successful_error_level = :warn
  c.non_whitelisted_requests_disabled = true # turn off all unrecorded/uncached requests, default is false
  # c.cache_whitelist = ["https://legal-framework-api-staging.cloud-platform.service.justice.gov.uk"]
  c.cache_path = "features/puffing-billy/request_cache"
  # c.certs_path = "features/puffing-billy/request_certs" # defaults to local /var/folders/.. dir, which is safe, but does not seem to work!?
  # c.proxy_host = 'example.com' # defaults to localhost
  # c.proxy_port = 12345 # defaults to random
  # c.proxied_request_host = nil
  # c.proxied_request_port = 80
  # c.record_requests = true # defaults to false
  c.cache_request_body_methods = %w[post patch put] # defaults to ['post']
end

Before("@billy") do
  Capybara.current_driver = if ENV["BROWSER"] == "chrome"
                              :selenium_chrome_billy
                            else
                              :selenium_chrome_headless_billy
                            end

  Billy.configure.record_requests = true if ENV["DEBUG"] || ENV["DEBUG_BILLY"]

  before_puffing_billy_stubs
end

After("@billy") do
  if ENV["DEBUG"] || ENV["DEBUG_BILLY"]
    puts "Requests received via Puffing Billy Proxy:"

    require "table_print"
    puts TablePrint::Printer.table_print(Billy.proxy.requests, [
      :status,
      :handler,
      :method,
      { url: { width: 500 } },
      :headers,
      { body: { width: 200 } },
    ])

    Billy.configure.record_requests = false
  end
end
