class BankHolidayUpdateWorker
  DataRetrievalError = Class.new(StandardError)
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  def perform
    sync_cached_data!
    return true if last_updated.updated_at > 1.month.ago
    return last_updated.touch if stored_data_current?

    latest_data.save!
  end

  def sync_cached_data!
    cached_dates = BankHolidayStore.read

    if (last_updated.present? && cached_dates.blank?) || cached_dates != last_updated.dates
      Rails.logger.info("Syncing cache store to latest bank holiday dates, last updated at #{last_updated.updated_at}")
      BankHolidayStore.write(last_updated.dates)
    end
  end

  def last_updated
    @last_updated ||= BankHoliday.by_updated_at.last || BankHoliday.create!
  end

  def latest_data
    @latest_data ||= begin
      bank_holiday = BankHoliday.new
      bank_holiday.populate_dates
      bank_holiday
    end
  end

  def stored_data_current?
    last_updated.dates == latest_data.dates
  end
end
