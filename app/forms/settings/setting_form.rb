module Settings
  class SettingForm < BaseForm
    form_for Setting

    attr_accessor :mock_true_layer_data,
                  :manually_review_all_cases,
                  :allow_welsh_translation,
                  :enable_ccms_submission,
                  :enable_mini_loop,
                  :enable_loop,
                  :enhanced_bank_upload,
                  :means_test_review_phase_one

    validates :mock_true_layer_data,
              :manually_review_all_cases,
              :allow_welsh_translation,
              :enable_ccms_submission,
              :enable_mini_loop,
              :enable_loop,
              :enhanced_bank_upload,
              :means_test_review_phase_one,
              presence: true
  end
end
