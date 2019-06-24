class MeritsAssessment < ApplicationRecord
  belongs_to :legal_aid_application

  enum success_prospect: {
    likely: 'likely'.freeze,
    marginal: 'marginal'.freeze,
    poor: 'poor'.freeze,
    borderline: 'borderline'.freeze,
    not_known: 'not_known'.freeze
  }, _prefix: true

  def self.prospects_unlikely_to_succeed
    MeritsAssessment.success_prospects.except(:likely).keys
  end
end
