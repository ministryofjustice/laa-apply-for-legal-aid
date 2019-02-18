module LegalAidApplications
  class OutstandingMortgageForm
    include BaseForm
    form_for LegalAidApplication
    attr_accessor :outstanding_mortgage_amount

    validates :outstanding_mortgage_amount, presence: { unless: :draft? }
    validates :outstanding_mortgage_amount, allow_blank: true, currency: { greater_than_or_equal_to: 0.0 }

    def attributes_to_clean
      [:outstanding_mortgage_amount]
    end
  end
end
