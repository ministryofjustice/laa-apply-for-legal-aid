namespace :job do
  namespace :bank_holiday_import do
    desc "Import bank holidays"
    task perform: :environment do
      Rails.logger.info "rake job:bank_holiday_import:perform queued at #{Time.zone.now}"
      BankHolidayUpdateWorker.perform_async
    end
  end
end
