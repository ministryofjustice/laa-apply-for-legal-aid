module Providers
  class ReceivedBenefitConfirmationForm
    include BaseForm

    form_for DWPOverride

    SINGLE_VALUE_ATTRIBUTES = %i[
      universal_credit
      guarantee_credit_element_of_pension_credit
      income_based_job_seekers_allowance
      income_related_employment_and_support_allowance
      income_support
    ].freeze

    attr_accessor :passporting_benefit

    validates :passporting_benefit, presence: true, unless: :draft?
  end
end
