require "vcr"

vcr_debug = ENV["VCR_DEBUG"].to_s == "true"
record_mode = ENV["VCR_RECORD_MODE"] ? ENV["VCR_RECORD_MODE"].to_sym : :once

VCR.configure do |vcr_config|
  vcr_config.cassette_library_dir = "spec/cassettes"
  vcr_config.hook_into :webmock

  vcr_config.default_cassette_options = {
    record: record_mode,
    match_requests_on: [:method, VCR.request_matchers.uri_without_param(:key)],
  }

  vcr_config.ignore_request do |request|
    uri = URI(request.uri).to_s
    uri.include?("__identify__") || uri =~ /127\.0\.0\.1.*(session|shutdown)/
  end

  vcr_config.configure_rspec_metadata!
  vcr_config.debug_logger = $stdout if vcr_debug
  vcr_config.filter_sensitive_data("<GOVUK_NOTIFY_API_KEY>") { ENV.fetch("GOVUK_NOTIFY_API_KEY", nil) }
  vcr_config.filter_sensitive_data("<ORDNANCE_SURVEY_API_KEY>") { ENV.fetch("ORDNANCE_SURVEY_API_KEY", nil) }
  vcr_config.filter_sensitive_data("<BC_LSC_SERVICE_NAME>") { ENV.fetch("BC_LSC_SERVICE_NAME", nil) }
  vcr_config.filter_sensitive_data("<BC_CLIENT_ORG_ID>") { ENV.fetch("BC_CLIENT_ORG_ID", nil) }
  vcr_config.filter_sensitive_data("<BC_CLIENT_USER_ID>") { ENV.fetch("BC_CLIENT_USER_ID", nil) }
  vcr_config.filter_sensitive_data("<PDA_AUTH_KEY>") { ENV.fetch("PDA_AUTH_KEY", nil) }
end
