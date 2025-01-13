GOOGLE_ANALYTICS_DOMAIN = "https://*.google-analytics.com".freeze

Rails.application.config.content_security_policy do |policy|
  policy.default_src :self
  policy.font_src :self, :data
  policy.img_src :self,
                 :data,
                 GOOGLE_ANALYTICS_DOMAIN,
                 "www.googletagmanager.com",
                 "https://truelayer-client-logos.s3-eu-west-1.amazonaws.com",
                 "https://truelayer-provider-assets.s3.amazonaws.com",
                 "https://providers-assets.truelayer.com"
  policy.object_src :none
  policy.style_src :self, :unsafe_inline
  policy.script_src :self,
                    GOOGLE_ANALYTICS_DOMAIN,
                    "https://www.googletagmanager.com"
  policy.connect_src :self,
                     GOOGLE_ANALYTICS_DOMAIN,
                     "https://*.justice.gov.uk"
end
Rails.application.config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
Rails.application.config.content_security_policy_nonce_directives = %w[script-src]
