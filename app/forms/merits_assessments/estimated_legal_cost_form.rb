module MeritsAssessments
  class EstimatedLegalCostForm
    include BaseForm

    form_for MeritsAssessment

    attr_accessor :estimated_legal_cost

    validates :estimated_legal_cost, presence: true, unless: :draft?
    validates :estimated_legal_cost, allow_blank: true, currency: { greater_than_or_equal_to: 0.0 }
  end
end
