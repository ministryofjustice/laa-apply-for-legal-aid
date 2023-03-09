class Setting < ApplicationRecord
  ATTRIBUTES = %i[
    mock_true_layer_data
    manually_review_all_cases
    allow_welsh_translation
    enable_ccms_submission
    means_test_review_phase_one
    partner_means_assessment
    new_flag
  ].freeze

  def self.method_missing(method_name, *args, &)
    attribute_or_predicate = method_name.to_s.tr("?", "").to_sym

    if attribute_or_predicate.in?(ATTRIBUTES)
      setting.public_send(method_name, *args, &)
    else
      super
    end
  end

  def self.respond_to_missing?(method_name, include_private = false)
    attribute_or_predicate = method_name.to_s.tr("?", "").to_sym
    attribute_or_predicate.in?(ATTRIBUTES) || super
  end

  def self.setting
    Setting.first || Setting.create!
  end

  def self.bank_transaction_filename
    setting.bank_transaction_filename
  end
end
