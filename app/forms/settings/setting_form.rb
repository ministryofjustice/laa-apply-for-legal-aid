module Settings
  class SettingForm < BaseForm
    form_for Setting

    attr_accessor :mock_true_layer_data,
                  :manually_review_all_cases,
                  :allow_welsh_translation,
                  :enable_ccms_submission,
                  :enable_employed_journey,
                  :enable_cfe_v5,
                  :enable_mini_loop

    validates :mock_true_layer_data,
              :manually_review_all_cases,
              :allow_welsh_translation,
              :enable_ccms_submission,
              :enable_employed_journey,
              :enable_cfe_v5,
              :enable_mini_loop,
              presence: true
  end
end
