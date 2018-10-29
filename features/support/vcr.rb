require 'vcr'

vcr_debug = ENV['VCR_DEBUG'].to_s == 'true'
record_mode = ENV['VCR_RECORD_MODE'] ? ENV['VCR_RECORD_MODE'].to_sym : :once
Capybara.server_port = 8234

VCR.configure do |vcr_config|
  vcr_config.cassette_library_dir = 'features/cassettes'
  vcr_config.hook_into :webmock
  vcr_config.default_cassette_options = {
    record: record_mode,
    match_requests_on: [:method, VCR.request_matchers.uri_without_param(:key)]
  }
  vcr_config.debug_logger = STDOUT if vcr_debug
  vcr_config.ignore_request do |request|
    uri = URI(request.uri)
    uri.to_s =~ /__identify__/ || uri.to_s =~ /127.0.0.1.*(session|shutdown)/
  end
end

VCR.cucumber_tags do |t|
  t.tag  '@localhost_request' # uses default record mode since no options are given
  t.tags '@disallowed_1', '@disallowed_2', record: :none
  t.tag  '@vcr', use_scenario_name: true
end
