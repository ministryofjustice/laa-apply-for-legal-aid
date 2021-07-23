module Settings
  class SettingForm
    include BaseForm

    form_for Setting

    attr_accessor :mock_true_layer_data,
                  :manually_review_all_cases,
                  :allow_welsh_translation,
                  :allow_multiple_proceedings,
                  :override_dwp_results,
                  :enable_ccms_submission

    validates :mock_true_layer_data,
              :manually_review_all_cases,
              :allow_welsh_translation,
              :allow_multiple_proceedings,
              :override_dwp_results,
              :enable_ccms_submission,
              presence: true
  end
end
