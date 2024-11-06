class ManualReviewDetailer
  def self.call(legal_aid_application)
    new(legal_aid_application).call
  end

  def initialize(legal_aid_application)
    @legal_aid_application = legal_aid_application
  end

  attr_reader :legal_aid_application

  delegate :has_restrictions?,
           :policy_disregards?,
           :capital_disregards?,
           :manually_entered_employment_information?,
           to: :legal_aid_application

  def call
    details = []
    details << I18n.t("shared.assessment_results.manual_check_required.restrictions") if has_restrictions?
    details << I18n.t("shared.assessment_results.manual_check_required.policy_disregards") if policy_disregards? || capital_disregards?
    details << I18n.t("shared.assessment_results.manual_check_required.extra_employment_information") if manually_entered_employment_information?
    details
  end
end
