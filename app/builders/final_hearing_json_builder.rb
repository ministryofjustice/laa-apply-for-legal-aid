class FinalHearingJsonBuilder
  extend NilSafeBuilder

  def initialize(final_hearing)
    @final_hearing = final_hearing
  end

  attr_reader :final_hearing

  delegate :id,
           :work_type,
           :listed,
           :date,
           :details,
           :created_at,
           :updated_at,
           to: :final_hearing

  def as_json
    return unless final_hearing

    {
      id:,
      work_type:,
      listed:,
      date:,
      details:,
      created_at:,
      updated_at:,
    }
  end
end
