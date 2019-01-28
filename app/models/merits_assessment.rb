class MeritsAssessment < ApplicationRecord
  belongs_to :legal_aid_application

  # defining before enum so it can be used in the enum
  def self.prospect_likely_to_succeed
    :likely
  end

  enum(
    success_prospect: {
      prospect_likely_to_succeed => '50% or better'.freeze,
      marginal: 'Marginal 45 - 50%'.freeze,
      borderline: 'borderline'.freeze,
      uncertain: 'uncertain'.freeze,
      poor: 'poor'.freeze
    },
    _prefix: true
  )

  def self.prospects_unlikely_to_succeed
    @prospects_unlikely_to_succeed ||= success_prospects.except(prospect_likely_to_succeed.to_s)
  end
end
