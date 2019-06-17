module MeritsAssessments
  class SuccessProspectForm
    include BaseForm

    form_for MeritsAssessment

    attr_accessor :success_prospect, :success_prospect_details

    validates :success_prospect, presence: true, unless: :draft?
    validates :success_prospect_details,
              presence: true,
              if: :details_required?

    private

    def details_required?
      return false if draft?

      success_prospect.present?
    end
  end
end
