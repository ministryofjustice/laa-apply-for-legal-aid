module LegalAidApplications
  class PropertyDetailsForm < BaseForm
    form_for LegalAidApplication

    ATTRIBUTES = %i[
      property_value
      outstanding_mortgage_amount
      shared_ownership
      percentage_home
    ].freeze

    attr_accessor(*ATTRIBUTES)

    validate :property_value_presence
    validate :property_value_amount

    validates :outstanding_mortgage_amount, presence: { unless: :outstanding_mortgage_amount_presence }
    validates :outstanding_mortgage_amount, allow_blank: true, currency: { greater_than_or_equal_to: 0.0 }

    validates :shared_ownership, presence: { unless: :draft? }

    validates :percentage_home, presence: {  unless: :draft? }
    validates :percentage_home, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_blank: true

    def attributes_to_clean
      %i[property_value outstanding_mortgage_amount]
    end

  private

    def property_value_presence
      return if draft? || property_value.present?

      errors.add(:property_value, I18n.t("activemodel.errors.models.legal_aid_application.attributes.property_value.blank#{individual}"))
    end

    def property_value_amount
      return if property_value.blank? || property_value.to_f >= 0.0

      errors.add(:property_value, I18n.t("activemodel.errors.models.legal_aid_application.attributes.property_value.greater_than_or_equal_to#{individual}"))
    end

    def individual
      return "_with_partner" if model.applicant.has_partner_with_no_contrary_interest?
    end

    def outstanding_mortgage_amount_presence
      draft? || model.own_home == "owned_outright"
    end
  end
end
