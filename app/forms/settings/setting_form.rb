module Settings
  class SettingForm < BaseForm
    form_for Setting

    attr_accessor :mock_true_layer_data,
                  :manually_review_all_cases,
                  :allow_welsh_translation,
                  :enable_ccms_submission,
                  :enable_employed_journey

    validates :mock_true_layer_data,
              :manually_review_all_cases,
              :allow_welsh_translation,
              :enable_ccms_submission,
              :enable_employed_journey,
              presence: true
  end
end
