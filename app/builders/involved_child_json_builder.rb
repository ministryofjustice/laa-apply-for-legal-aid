class InvolvedChildJsonBuilder
  extend NilSafeBuilder

  def initialize(involved_child)
    @involved_child = involved_child
  end

  attr_reader :involved_child

  delegate :id,
           :full_name,
           :date_of_birth,
           :created_at,
           :updated_at,
           :ccms_opponent_id,
           to: :involved_child

  def as_json
    return unless involved_child

    {
      id:,
      full_name:,
      date_of_birth:,
      created_at:,
      updated_at:,
      ccms_opponent_id:,
    }
  end
end
