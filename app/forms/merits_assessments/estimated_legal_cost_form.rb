module MeritsAssessments
  class EstimatedLegalCostForm
    include BaseForm

    form_for MeritsAssessment

    attr_accessor :estimated_legal_cost

    validates :estimated_legal_cost, numericality: { greater_than_or_equal_to: 0 }, allow_blank: true
    validates :estimated_legal_cost, presence: true
  end
end
