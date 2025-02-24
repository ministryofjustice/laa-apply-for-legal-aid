# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

GOOGLE_ANALYTICS_DOMAIN = "https://*.google-analytics.com".freeze

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.font_src    :self, :data
    policy.img_src     :self,
                       :data,
                       GOOGLE_ANALYTICS_DOMAIN,
                       "www.googletagmanager.com",
                       "https://truelayer-client-logos.s3-eu-west-1.amazonaws.com",
                       "https://truelayer-provider-assets.s3.amazonaws.com",
                       "https://providers-assets.truelayer.com"
    policy.object_src  :none
    policy.style_src   :self, :unsafe_inline
    policy.script_src  :self,
                       GOOGLE_ANALYTICS_DOMAIN,
                       "https://www.googletagmanager.com"
    policy.connect_src :self,
                       GOOGLE_ANALYTICS_DOMAIN,
                       "https://*.justice.gov.uk"
    # Specify URI for violation reports
    # policy.report_uri "/csp-violation-report-endpoint"
  end

  # Generate session nonces for permitted importmap, inline scripts, and inline styles.
  config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
  config.content_security_policy_nonce_directives = %w[script-src style-src]

  # Report violations without enforcing the policy.
  # config.content_security_policy_report_only = true
end
