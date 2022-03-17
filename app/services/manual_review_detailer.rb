class ManualReviewDetailer
  def self.call(legal_aid_application)
    new(legal_aid_application).call
  end

  def initialize(legal_aid_application)
    @legal_aid_application = legal_aid_application
  end

  def call
    details = []
    details << I18n.t("shared.assessment_results.manual_check_required.restrictions") if @legal_aid_application.has_restrictions?
    details << I18n.t("shared.assessment_results.manual_check_required.policy_disregards") if @legal_aid_application.policy_disregards?
    details << I18n.t("shared.assessment_results.manual_check_required.extra_employment_information") if @legal_aid_application.manually_entered_employment_information?
    details
  end
end
