class SecureApplicationFinder
  def initialize(token)
    @token = token
  end

  def error
    return :expired if expired?
  end

  delegate :legal_aid_application, to: :citizen_access_token

private

  def citizen_access_token
    @citizen_access_token ||= Citizen::AccessToken.find_by!(token: @token)
  end

  def expired?
    citizen_access_token.expires_on <= Date.current
  end
end
