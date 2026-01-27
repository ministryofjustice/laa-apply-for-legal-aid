require "webmock/rspec"

allowed_sites = [
  lambda do |uri|
    [
      /__identify__/,
      /127.0.0.1.*(session|shutdown|status)/,
      /chromedriver\.storage\.googleapis\.com/,
    ].any? { |pattern| uri.to_s =~ pattern }
  end,
]

# NOTE: net_http_connect_on_start is required to have capybara and webmock play nice in system specs but can
# prevent stubbing in other specs (such as request specs). see https://github.com/bblimke/webmock/issues/914
#
WebMock.disable_net_connect!(allow: allowed_sites, net_http_connect_on_start: %w[localhost 127.0.0.1])
