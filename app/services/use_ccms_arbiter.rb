class UseCCMSArbiter
  attr_reader :legal_aid_application

  delegate :provider, to: :legal_aid_application

  def self.call(legal_aid_application)
    new(legal_aid_application).call
  end

  def initialize(legal_aid_application)
    @legal_aid_application = legal_aid_application
  end

  def call
    return false if applicant_receives_benefit_and_provider_has_passported_permissions?

    return false if applicant_does_not_receive_benefit_and_provider_has_non_passported_permissions?

    legal_aid_application.use_ccms!(:non_passported) unless legal_aid_application.use_ccms?
    true
  end

private

  def applicant_receives_benefit_and_provider_has_passported_permissions?
    legal_aid_application.applicant_receives_benefit? && provider.passported_permissions?
  end

  def applicant_does_not_receive_benefit_and_provider_has_non_passported_permissions?
    !legal_aid_application.applicant_receives_benefit? && provider.non_passported_permissions?
  end
end
