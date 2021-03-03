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

  def self.allow_multiple_proceedings?
    setting.allow_multiple_proceedings
  end

  def self.override_dwp_results?
    setting.override_dwp_results
  end

  def self.setting
    Setting.first || Setting.create!
  end
end
