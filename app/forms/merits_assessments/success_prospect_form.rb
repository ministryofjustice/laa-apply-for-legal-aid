module MeritsAssessments
  class SuccessProspectForm
    include BaseForm

    form_for MeritsAssessment

    attr_accessor :success_prospect, :success_prospect_details

    before_validation :clear_success_prospect_details
    validates :success_prospect, presence: true, unless: :draft?
    validates :success_prospect_details,
              presence: true,
              unless: :details_not_required?

    private

    def clear_success_prospect_details
      success_prospect_details&.clear if success_prospect.to_s == MeritsAssessment.prospect_likely_to_succeed.to_s
    end

    def details_not_required?
      return true if success_prospect.to_s == MeritsAssessment.prospect_likely_to_succeed.to_s
      return true if draft? && success_prospect.blank?

      false
    end
  end
end
