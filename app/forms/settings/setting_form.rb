module Settings
  class SettingForm < BaseForm
    form_for Setting

    attr_accessor :mock_true_layer_data,
                  :manually_review_all_cases,
                  :allow_welsh_translation,
                  :enable_ccms_submission,
                  :linked_applications,
                  :collect_hmrc_data,
                  :mock_entra_id

    validates :mock_true_layer_data,
              :manually_review_all_cases,
              :allow_welsh_translation,
              :enable_ccms_submission,
              :linked_applications,
              :collect_hmrc_data,
              :mock_entra_id,
              presence: true
  end
end
