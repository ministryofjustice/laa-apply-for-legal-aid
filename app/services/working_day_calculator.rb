class WorkingDayCalculator
  def self.working_days_from_now(number)
    new(Date.today).add_working_days(number)
  end

  attr_reader :date

  def initialize(date)
    @date = date
  end

  def add_working_days(number)
    calendar.add_business_days(date, number)
  end

  def calendar
    @calendar ||= Business::Calendar.new(holidays: BankHoliday.dates)
  end
end
