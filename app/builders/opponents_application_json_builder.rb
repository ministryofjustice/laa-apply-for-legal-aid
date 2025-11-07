class OpponentsApplicationJsonBuilder
  extend NilSafeBuilder

  def initialize(opponents_application)
    @opponents_application = opponents_application
  end

  attr_reader :opponents_application

  delegate :id,
           :has_opponents_application,
           :reason_for_applying,
           :created_at,
           :updated_at,
           to: :opponents_application

  def as_json
    return unless opponents_application

    {
      id:,
      has_opponents_application:,
      reason_for_applying:,
      created_at:,
      updated_at:,
    }
  end
end
