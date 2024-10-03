module LegalAidApplications
  class OwnHomeForm < BaseForm
    form_for LegalAidApplication

    attr_accessor :own_home

    validates :own_home, presence_partner_optional: { partner_labels: :has_partner_with_no_contrary_interest? }, unless: :draft?

    def save!
      model.update!(attributes_to_reset)
      super
    end

    def attributes_to_reset
      if own_home == "no"
        {
          property_value: nil,
          outstanding_mortgage_amount: nil,
          shared_ownership: nil,
          percentage_home: nil,
        }
      elsif own_home == "owned_outright"
        {
          outstanding_mortgage_amount: nil,
        }
      else
        {}
      end
    end
  end
end
