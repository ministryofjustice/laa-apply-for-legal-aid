module LegalAidApplications
  class OpenBankingConsentForm
    include BaseForm

    form_for LegalAidApplication

    ATTRIBUTES = %i[citizen_uses_online_banking provider_received_citizen_consent].freeze

    attr_accessor(*ATTRIBUTES)
    attr_accessor :none_selected

    before_validation :empty_unchecked_values

    validate :any_checkbox_checked_or_draft

    def any_checkbox_checked?
      (ATTRIBUTES + [:none_selected]).map { |attribute| __send__(attribute) }.any?(&:present?)
    end

    def exclude_from_model
      [:none_selected]
    end

    def save
      super
      model.use_ccms! unless model.online_banking_consent?
    end

    private

    def empty_unchecked_values
      ATTRIBUTES.each do |attribute|
        if __send__(attribute).blank?
          attributes[attribute] = false
          instance_variable_set(:"@#{attribute}", false)
        end
      end
    end

    def any_checkbox_checked_or_draft
      errors.add :base, error_message_for_none_selected unless any_checkbox_checked? || draft?
    end

    def error_message_for_none_selected
      I18n.t('activemodel.errors.models.legal_aid_application.attributes.open_banking_consents.base.none_selected')
    end
  end
end
