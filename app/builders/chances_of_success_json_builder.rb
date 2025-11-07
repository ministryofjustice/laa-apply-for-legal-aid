class ChancesOfSuccessJsonBuilder
  extend NilSafeBuilder

  def initialize(chances_of_success)
    @chances_of_success = chances_of_success
  end

  attr_reader :chances_of_success

  delegate :id,
           :details,
           :created_at,
           :updated_at,
           to: :chances_of_success

  def as_json
    return unless chances_of_success

    {
      id:,
      details:,
      created_at:,
      updated_at:,
    }
  end
end
