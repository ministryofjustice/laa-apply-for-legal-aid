module Providers
  class ReceivedBenefitConfirmationForm < BaseForm
    RadioOption = Struct.new(:value, :label)

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

    def self.radio_options
      translation_root = 'shared.forms.received_benefit_confirmation.form.providers.received_benefit_confirmations'
      SINGLE_VALUE_ATTRIBUTES.map { |benefit| RadioOption.new(benefit, I18n.t("#{translation_root}.#{benefit}")) }
    end
  end
end
