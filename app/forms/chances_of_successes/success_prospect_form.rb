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
    validate :details_present?

    def initialize(*args)
      super

      extrapolate_details
    end

    private

    def details_present?
      return if success_prospect.blank? || draft?

      details = "success_prospect_details_#{success_prospect}".to_sym
      value = __send__(details)
      errors.add(details, I18n.t('activemodel.errors.models.chances_of_success.attributes.success_prospect_details.blank')) if value.blank?
    end

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

    def success_prospect_details_expandable?
      success_prospect_details.present? && __send__("success_prospect_details_#{success_prospect}").nil?
    end
  end
end
