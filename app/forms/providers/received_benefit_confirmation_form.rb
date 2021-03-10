module Providers
  class ReceivedBenefitConfirmationForm
    include BaseForm

    form_for DWPOverride

    attr_accessor :passporting_benefit

    SINGLE_VALUE_ATTRIBUTES = %i[
      universal_credit
      guarantee_credit_element_of_pension_credit
      income_based_job_seekers_allowance
      income_related_employment_and_support_allowance
      income_support
    ].freeze
  end
end


    # CHECK_BOXES_ATTRIBUTES = (SINGLE_VALUE_ATTRIBUTES.map(&:to_sym) + %i[none_selected]).freeze

    # attr_accessor(*CHECK_BOXES_ATTRIBUTES)

    # validate :any_checkbox_checked_or_draft

    # def any_checkbox_checked?
    #   CHECK_BOXES_ATTRIBUTES.map { |attribute| __send__(attribute) }.any?(&:present?)
    # end

    # private

    # def any_checkbox_checked_or_draft
    #   errors.add :base, error_message_for_none_selected unless any_checkbox_checked? || draft?
    # end

    # def error_message_for_none_selected
    #   I18n.t('activemodel.errors.models.policy_disregards.attributes.base.none_selected')
    # end
