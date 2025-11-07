class AttemptsToSettleJsonBuilder
  extend NilSafeBuilder

  def initialize(attempts_to_settle)
    @attempts_to_settle = attempts_to_settle
  end

  attr_reader :attempts_to_settle

  delegate :id,
           :attempts_made,
           :created_at,
           :updated_at,
           to: :attempts_to_settle

  def as_json
    return unless attempts_to_settle

    {
      id:,
      attempts_made:,
      created_at:,
      updated_at:,
    }
  end
end
