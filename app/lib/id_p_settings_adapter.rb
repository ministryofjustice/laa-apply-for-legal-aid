class IdPSettingsAdapter
  def self.settings(_idp_entity_id)
    if mock_saml?
      mock_settings
    else
      standard_settings
    end
  end

  def self.mock_settings # rubocop:disable Metrics/MethodLength
    {
      security: {
        authn_requests_signed: false,
        want_assertions_signed: false,
        digest_method: '',
        signature_method: ''
      },
      certificate: nil,
      private_key: nil,
      idp_cert: nil,
      issuer: "#{Rails.configuration.x.application.host_url}/",
      idp_cert_fingerprint: '9E:65:2E:03:06:8D:80:F2:86:C7:6C:77:A1:D9:14:97:0A:4D:F4:4D',
      idp_sso_target_url: '/saml/auth'
    }
  end

  def self.standard_settings
    {
      idp_sso_target_url: laa_portal_config.idp_sso_target_url,
      issuer: 'apply',
      idp_cert_fingerprint_algorithm: laa_portal_config.idp_cert_fingerprint_algorithm
    }
  end

  def self.laa_portal_config
    Rails.configuration.x.laa_portal
  end

  def self.mock_saml?
    ActiveRecord::Type::Boolean.new.cast(laa_portal_config.mock_saml) || false
  end
end
