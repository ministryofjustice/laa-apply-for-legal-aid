class WorkingDayCalculator
  ParameterError = Class.new(StandardError)

  def self.working_days_from_now(number)
    call(working_days: number)
  end

  def self.call(working_days:, from: Date.today)
    new(from).add_working_days(working_days)
  end

  attr_reader :date

  def initialize(date)
    raise ParameterError, 'No date present' unless date

    @date = date
  end

  def add_working_days(number)
    calendar.add_business_days(date, number)
  end

  def calendar
    @calendar ||= Business::Calendar.new(holidays: BankHoliday.dates)
  end
end
