class Setting < ApplicationRecord
  def self.mock_true_layer_data?
    setting.mock_true_layer_data?
  end

  def self.setting
    Setting.first || Setting.create!
  end
end
