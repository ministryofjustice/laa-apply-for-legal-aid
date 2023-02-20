class SecureApplicationFinder
  attr_reader :secure_id

  def initialize(secure_id)
    @secure_id = secure_id
  end

  def error
    @error ||= check_for_errors
  end

  def legal_aid_application
    LegalAidApplication.find_by!(citizen_url_id: secure_id)
  rescue ActiveRecord::RecordNotFound
    LegalAidApplication.find_by! secure_data[:legal_aid_application]
  end

private

  def secure_data
    @secure_data ||= SecureData.for(secure_id)
  end

  def check_for_errors
    return :expired if expired?
  end

  def expired?
    expires_on && expires_on < Time.current
  end

  def expires_on
    legal_aid_application.citizen_url_expires_on.presence || secure_data[:expired_at]
  end
end
