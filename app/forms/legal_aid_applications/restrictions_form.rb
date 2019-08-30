module LegalAidApplications
  class RestrictionsForm
    include BaseForm

    form_for LegalAidApplication

    attr_accessor :has_restrictions, :restrictions_details, :journey

    before_validation :clear_restrictions_details

    validate :restrictions_presence
    validate :restrictions_details_presence

    private

    def restrictions_presence
      return if draft? || has_restrictions.present?

      add_blank_error_for :has_restrictions
    end

    def restrictions_details_presence
      return if draft? || has_restrictions.to_s != 'true'

      add_blank_error_for :restrictions_details if restrictions_details.blank?
    end

    def add_blank_error_for(attribute)
      errors.add(attribute, I18n.t("activemodel.errors.models.legal_aid_application.attributes.#{attribute}.#{journey}.blank"))
    end

    def exclude_from_model
      [:journey]
    end

    def clear_restrictions_details
      restrictions_details&.clear if has_restrictions.to_s == 'false'
    end
  end
end
