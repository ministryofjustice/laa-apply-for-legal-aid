Rails.application.config.content_security_policy do |policy|
  policy.default_src :self
  policy.font_src :self, :data
  policy.img_src :self,
                 :data,
                 "https://www.google-analytics.com",
                 "www.googletagmanager.com",
                 "https://truelayer-client-logos.s3-eu-west-1.amazonaws.com",
                 "https://truelayer-provider-assets.s3.amazonaws.com"
  policy.object_src :none
  policy.style_src :self, :unsafe_inline

  if Rails.env.development?
    policy.script_src :self,
                      "https://www.google-analytics.com",
                      "https://www.googletagmanager.com",
                      :unsafe_inline
    policy.connect_src :self,
                       "https://www.google-analytics.com",
                       "https://*.justice.gov.uk"
  else
    policy.script_src :self,
                      "https://www.google-analytics.com",
                      "https://www.googletagmanager.com"
    policy.connect_src :self,
                       "https://www.google-analytics.com",
                       "https://*.justice.gov.uk",
                       "http://localhost:*"
  end
end

Rails.application.config.content_security_policy_nonce_generator = ->(_request) { SecureRandom.base64(16) }
