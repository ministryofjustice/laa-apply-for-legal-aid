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

    validates :property_value, presence_partner_optional: { partner_labels: :has_partner_with_no_contrary_interest? }, unless: :draft?
    validates :property_value, allow_blank: true, currency: { greater_than_or_equal_to: 0.0, partner_labels: :has_partner_with_no_contrary_interest? }

    validates :outstanding_mortgage_amount, presence: { unless: :outstanding_mortgage_amount_presence? }
    validates :outstanding_mortgage_amount, allow_blank: true, currency: { greater_than_or_equal_to: 0.0 }

    validates :shared_ownership, presence_partner_optional: { partner_labels: :has_partner_with_no_contrary_interest? }, unless: :draft?

    validates :percentage_home, presence_partner_optional: { partner_labels: :has_partner_with_no_contrary_interest? }, unless: :draft?
    validates :percentage_home, allow_blank: true, numericality_partner_optional: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100, partner_labels: :has_partner_with_no_contrary_interest? }

    def attributes_to_clean
      %i[property_value outstanding_mortgage_amount]
    end

  private

    def outstanding_mortgage_amount_presence?
      draft? || model.own_home == "owned_outright"
    end
  end
end
