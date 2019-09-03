class SubstantiveApplicationDeadlineCalculator
  def self.call(legal_aid_application)
    new(legal_aid_application).deadline
  end

  attr_reader :legal_aid_application

  def initialize(legal_aid_application)
    @legal_aid_application = legal_aid_application
  end
  delegate :used_delegated_functions_on, to: :legal_aid_application

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
