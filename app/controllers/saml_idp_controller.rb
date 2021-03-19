class SamlIdpController < SamlIdp::IdpController
  def create
    if params[:email].present?
      provider = idp_authenticate(params[:email], params[:password])
      if provider.nil?
        @saml_idp_fail_msg = 'Incorrect email or password.'
      else
        @saml_response = idp_make_saml_response(provider, params[:email])
        render template: 'saml_idp/idp/saml_post', layout: false
        return
      end
    end
    render template: 'saml_idp/idp/new'
  end

  private

  def idp_authenticate(email, password)
    return unless config.password == password

    user = Provider.find_by(email: email)
    return unless user

    user
  end

  def idp_make_saml_response(provider, email)
    encode_SAMLResponse(provider.username, {}, USER_EMAIL: email)
  end

  def config
    Rails.configuration.x.application.mock_saml
  end
end
