class SecureApplicationFinder
  attr_reader :secure_id

  def initialize(secure_id)
    @secure_id = secure_id
  end

  def error
    @error ||= check_for_errors
  end

  def legal_aid_application
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
    secure_data[:expired_at] && secure_data[:expired_at] < Time.current
  end
end
