module MeritsAssessments
  class SuccessProspectForm
    include BaseForm

    form_for MeritsAssessment

    attr_accessor :success_prospect, :success_prospect_details

    before_validation :clear_success_prospect_details
    validates :success_prospect, presence: true
    validates :success_prospect_details,
              presence: true,
              unless: proc { |form| form.success_prospect.to_s == MeritsAssessment.prospect_likely_to_succeed.to_s }

    private

    def clear_success_prospect_details
      success_prospect_details.clear if success_prospect.to_s == MeritsAssessment.prospect_likely_to_succeed.to_s
    end
  end
end
