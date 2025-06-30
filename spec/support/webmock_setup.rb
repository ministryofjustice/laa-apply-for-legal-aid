require "webmock/rspec"

allowed_sites = [
  lambda do |uri|
    [
      /__identify__/,
      /127.0.0.1.*(session|shutdown)/,
      /chromedriver\.storage\.googleapis\.com/,
    ].any? { |pattern| uri.to_s =~ pattern }
  end,
]

WebMock.disable_net_connect!(allow: allowed_sites, net_http_connect_on_start: true)
