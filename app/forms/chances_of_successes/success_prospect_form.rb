module ChancesOfSuccesses
  class SuccessProspectForm
    include BaseForm

    form_for ProceedingMeritsTask::ChancesOfSuccess

    SUCCESS_PROSPECT_DETAILS = %i[
      success_prospect_details_marginal
      success_prospect_details_poor
      success_prospect_details_borderline
      success_prospect_details_not_known
    ].freeze

    OTHER_ATTRIBUTES = %i[
      success_prospect
      success_prospect_details
    ].freeze

    ALL_ATTRIBUTES = SUCCESS_PROSPECT_DETAILS + OTHER_ATTRIBUTES

    attr_accessor(*ALL_ATTRIBUTES)

    before_validation :interpolate_details

    def exclude_from_model
      SUCCESS_PROSPECT_DETAILS
    end

    validates :success_prospect, presence: true, unless: :draft?
    validates :success_prospect_details,
              presence: true,
              if: :details_required?

    def initialize(*args)
      super

      extrapolate_details
    end

    private

    def interpolate_details
      return unless %w[poor marginal borderline not_known].include?(success_prospect)

      value = __send__("success_prospect_details_#{success_prospect}".to_sym)
      @success_prospect_details = value&.empty? ? nil : value
      attributes['success_prospect_details'] = @success_prospect_details
    end

    def extrapolate_details
      return unless %w[poor marginal borderline not_known].include?(success_prospect)
      return unless success_prospect_details_expandable?

      field = "success_prospect_details_#{success_prospect}"
      __send__("#{field}=", success_prospect_details)
      attributes[field] = success_prospect_details
    end

    def details_required?
      return false if draft?

      success_prospect.present?
    end

    def success_prospect_details_expandable?
      success_prospect_details.present? && __send__("success_prospect_details_#{success_prospect}").nil?
    end
  end
end
