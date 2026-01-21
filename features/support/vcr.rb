require "vcr"

vcr_debug = ENV["VCR_DEBUG"].to_s == "true"
record_mode = ENV["VCR_RECORD_MODE"] ? ENV["VCR_RECORD_MODE"].to_sym : :once
Capybara.server_port = 8234

VCR.configure do |vcr_config|
  vcr_config.cassette_library_dir = "features/cassettes"
  vcr_config.hook_into :faraday, :webmock
  vcr_config.default_cassette_options = {
    record: record_mode,
    match_requests_on: [:method, VCR.request_matchers.uri_without_param(:key)],
  }
  vcr_config.debug_logger = $stdout if vcr_debug

  vcr_config.ignore_request do |request|
    uri = URI(request.uri).to_s
    uri.include?("__identify__") || uri =~ /127\.0\.0\.1.*(session|shutdown|status)/
  end

  vcr_config.filter_sensitive_data("<GOVUK_NOTIFY_API_KEY>") { ENV.fetch("GOVUK_NOTIFY_API_KEY", nil) }
  vcr_config.filter_sensitive_data("<ORDNANCE_SURVEY_API_KEY>") { ENV.fetch("ORDNANCE_SURVEY_API_KEY", nil) }
  vcr_config.filter_sensitive_data("<BC_LSC_SERVICE_NAME>") { ENV.fetch("BC_LSC_SERVICE_NAME", nil) }
  vcr_config.filter_sensitive_data("<BC_CLIENT_ORG_ID>") { ENV.fetch("BC_CLIENT_ORG_ID", nil) }
  vcr_config.filter_sensitive_data("<BC_CLIENT_USER_ID>") { ENV.fetch("BC_CLIENT_USER_ID", nil) }
  vcr_config.filter_sensitive_data("<OMNIAUTH_ENTRAID_CLIENT_ID>") { ENV.fetch("OMNIAUTH_ENTRAID_CLIENT_ID", nil) }
  vcr_config.filter_sensitive_data("<OMNIAUTH_ENTRAID_CLIENT_SECRET>") { ENV.fetch("OMNIAUTH_ENTRAID_CLIENT_SECRET", nil) }
  vcr_config.filter_sensitive_data("<OMNIAUTH_ENTRAID_REDIRECT_URI>") { ENV.fetch("OMNIAUTH_ENTRAID_REDIRECT_URI", nil) }
  vcr_config.filter_sensitive_data("<OMNIAUTH_ENTRAID_TENANT_ID>") { ENV.fetch("OMNIAUTH_ENTRAID_TENANT_ID", nil) }
  vcr_config.filter_sensitive_data("<PDA_AUTH_KEY>") { ENV.fetch("PDA_AUTH_KEY", nil) }
  vcr_config.filter_sensitive_data("<CCMS_USER_API_AUTH_KEY>") { ENV.fetch("CCMS_USER_API_AUTH_KEY", nil) }
end

VCR.cucumber_tags do |t|
  t.tags "@disallowed_1", "@disallowed_2", record: :none
  t.tag  "@vcr", use_scenario_name: true
end
