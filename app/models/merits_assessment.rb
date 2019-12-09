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
    success_prospects.except(:likely).keys
  end

  def submit!
    update!(submitted_at: Time.current) unless submitted_at?
    ActiveSupport::Notifications.instrument 'dashboard.merits_assessment_submitted'
  end
end
