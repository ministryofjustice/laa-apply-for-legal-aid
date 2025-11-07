class ProhibitedStepsJsonBuilder
  extend NilSafeBuilder

  def initialize(prohibited_steps)
    @prohibited_steps = prohibited_steps
  end

  attr_reader :prohibited_steps

  delegate :id,
           :uk_removal,
           :details,
           :created_at,
           :updated_at,
           to: :prohibited_steps

  def as_json
    return unless prohibited_steps

    {
      id:,
      uk_removal:,
      details:,
      created_at:,
      updated_at:,
    }
  end
end
