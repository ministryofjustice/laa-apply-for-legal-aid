class WorkingDayCalculator
  ParameterError = Class.new(StandardError)

  def self.working_days_from_now(number)
    call(working_days: number)
  end

  def self.call(working_days:, from: Time.zone.today)
    new(from).working_days_from_date(working_days)
  end

  def self.working_days_between(date1, date2)
    new(date1).calendar.business_days_between(date1, date2)
  end

  attr_reader :date

  def initialize(date)
    raise ParameterError, "No date present" unless date

    @date = date
  end

  def working_days_from_date(number)
    number.positive? ? add_working_days(number) : subtract_working_days(number)
  end

  def add_working_days(number)
    calendar.add_business_days(date, number)
  end

  def subtract_working_days(number)
    calendar.subtract_business_days(date, number.abs)
  end

  def calendar
    @calendar ||= Business::Calendar.new(name: :working_days_calculator, holidays: BankHolidayStore.read)
  end
end
