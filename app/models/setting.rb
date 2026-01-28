class Setting < ApplicationRecord
  def self.mock_true_layer_data?
    setting.mock_true_layer_data?
  end

  def self.bank_transaction_filename
    setting.bank_transaction_filename
  end

  def self.manually_review_all_cases?
    setting.manually_review_all_cases
  end

  def self.allow_welsh_translation?
    setting.allow_welsh_translation
  end

  def self.enable_ccms_submission?
    setting.enable_ccms_submission
  end

  def self.alert_via_sentry?
    setting.alert_via_sentry
  end

  def self.collect_hmrc_data?
    setting.collect_hmrc_data
  end

  def self.collect_dwp_data?
    setting.collect_dwp_data
  end

  def self.enable_datastore_submission?
    setting.enable_datastore_submission
  end

  def self.setting
    Setting.first || Setting.create!
  end

  def self.out_of_hours?
    # Provider access to the service only permitted between 7AM and 9:30PM, Citizen access is required 24/7.
    # This can be overridden on different environments for testing.
    #
    # Note: BankHolidayStore cache falls back to [] to avoid blocking access when the cache is empty
    #
    Time.zone.today.iso8601.in?(BankHolidayStore.read) ||
      Time.zone.now < Rails.configuration.x.business_hours.start.to_time ||
      Time.zone.now >= Rails.configuration.x.business_hours.end.to_time
  end
end
