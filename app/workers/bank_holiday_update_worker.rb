class BankHolidayUpdateWorker
  DataRetrievalError = Class.new(StandardError)
  include Sidekiq::Worker

  UPDATE_INTERVAL = 2.days

  def perform
    return true if last_updated.updated_at > UPDATE_INTERVAL.ago
    return last_updated.touch if stored_data_current?

    lastest_data.save!
  end

  def last_updated
    @last_updated ||= BankHoliday.by_updated_at.last
  end

  def lastest_data
    @lastest_data ||= begin
      bank_holiday = BankHoliday.new
      bank_holiday.populate_dates
      bank_holiday
    end
  end

  def stored_data_current?
    last_updated.dates == lastest_data.dates
  end
end
