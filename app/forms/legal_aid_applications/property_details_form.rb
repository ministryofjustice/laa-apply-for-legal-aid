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

    validates :property_value, presence: { unless: :draft? }
    validates :property_value, allow_blank: true, currency: { greater_than_or_equal_to: 0.0 }

    validates :outstanding_mortgage_amount, presence: { unless: :draft? || model.own_home == "owned_outright" }
    validates :outstanding_mortgage_amount, allow_blank: true, currency: { greater_than_or_equal_to: 0.0 }

    validates :shared_ownership, presence: { unless: :draft? }

    validates :percentage_home, presence: {  unless: :draft? }
    validates :percentage_home, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_blank: true

    def attributes_to_clean
      %i[property_value outstanding_mortgage_amount]
    end
  end
end
