class Setting < ApplicationRecord
  def self.mock_true_layer_data?
    setting.mock_true_layer_data?
  end

  def self.bank_transaction_filename
    setting.bank_transaction_filename
  end

  def self.allow_non_passported_route?
    return false unless Rails.configuration.x.allow_non_passported_route

    setting.allow_non_passported_route?
  end

  def self.manually_review_all_cases?
    setting.manually_review_all_cases
  end

  def self.setting
    Setting.first || Setting.create!
  end
end
