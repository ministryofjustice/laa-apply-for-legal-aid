class SubstantiveApplicationDeadlineCalculator
  def self.call(df_date)
    new(df_date).deadline
  end

  def initialize(df_date)
    @df_date = df_date
  end

  def deadline
    WorkingDayCalculator.call(
      working_days: number_of_days_to_deadline,
      from: @df_date
    )
  end

  def number_of_days_to_deadline
    LegalAidApplication::WORKING_DAYS_TO_COMPLETE_SUBSTANTIVE_APPLICATION
  end
end
