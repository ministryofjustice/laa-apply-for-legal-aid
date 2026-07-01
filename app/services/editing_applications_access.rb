class EditingApplicationsAccess
  BLOCKED_STEPS_FOR_EDITING_APPLICATIONS = %i[
    applicant_details
    has_national_insurance_numbers
  ].freeze

  def initialize(legal_aid_application)
    @legal_aid_application = legal_aid_application
  end

  def can_access?(step)
    return true unless return_to_review_and_print?

    !step.to_sym.in?(BLOCKED_STEPS_FOR_EDITING_APPLICATIONS)
  end

private

  attr_reader :legal_aid_application

  def return_to_review_and_print?
    legal_aid_application.return_to_review_and_print?
  end
end
