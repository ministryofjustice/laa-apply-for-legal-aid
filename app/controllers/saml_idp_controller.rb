class SamlIdpController < SamlIdp::IdpController
  def create
    unless params[:email].blank?
      provider = idp_authenticate(params[:email], params[:password])
      if provider.nil?
        @saml_idp_fail_msg = 'Incorrect email or password.'
      else
        @saml_response = idp_make_saml_response(provider)
        render template: 'saml_idp/idp/saml_post', layout: false
        return
      end
    end
    render template: 'saml_idp/idp/new'
  end

  private

  def idp_authenticate(email, password)
    return unless config.usernames.include?(email) && config.password == password

    Provider.find_or_create_by(username: email) do |provider|
      provider.type = 'Provider'
    end
  end

  def idp_make_saml_response(provider)
    encode_SAMLResponse(provider.username)
  end

  def config
    Rails.configuration.x.application.mock_saml
  end
end
