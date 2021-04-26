class SubstantiveApplicationDeadlineCalculator
  def self.call(record)
    new(record).deadline
  end

  attr_reader :record

  delegate :used_delegated_functions_on, to: :record

  def initialize(record)
    @record = record
  end

  def deadline
    WorkingDayCalculator.call(
      working_days: number_of_days_to_deadline,
      from: used_delegated_functions_on
    )
  end

  def number_of_days_to_deadline
    LegalAidApplication::WORKING_DAYS_TO_COMPLETE_SUBSTANTIVE_APPLICATION
  end
end
