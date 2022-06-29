# rubocop:disable Lint/PercentStringArray
connect_src = %w['self' https://www.google-analytics.com https://*.justice.gov.uk]
connect_src << "http://localhost:*" if Rails.env.development?

SecureHeaders::Configuration.configure do |config|
  config.csp = {
    default_src: %w['self'],
    img_src: %w['self'
                data:
                https://www.google-analytics.com
                www.googletagmanager.com
                https://truelayer-client-logos.s3-eu-west-1.amazonaws.com
                https://truelayer-provider-assets.s3.amazonaws.com],
    script_src: %w['self' nonce https://www.google-analytics.com https://www.googletagmanager.com],
    style_src: %w['self' 'unsafe-inline'],
    object_src: %w['none'],
    connect_src:,
  }
end
# rubocop:enable Lint/PercentStringArray
