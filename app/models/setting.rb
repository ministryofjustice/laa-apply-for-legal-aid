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

  def self.linked_applications?
    setting.linked_applications
  end

  def self.collect_hmrc_data?
    setting.collect_hmrc_data
  end

  def self.special_childrens_act?
    setting.special_childrens_act
  end

  def self.means_test_review_a?
    setting.means_test_review_a && Time.zone.today >= Rails.configuration.x.mtr_a_start_date
  end

  def self.public_law_family?
    setting.public_law_family
  end

  def self.setting
    Setting.first || Setting.create!
  end
end
