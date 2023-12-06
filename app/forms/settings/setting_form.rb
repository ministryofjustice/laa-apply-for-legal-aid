module Settings
  class SettingForm < BaseForm
    form_for Setting

    attr_accessor :mock_true_layer_data,
                  :manually_review_all_cases,
                  :allow_welsh_translation,
                  :enable_ccms_submission,
                  :partner_means_assessment,
                  :linked_applications,
                  :cya_summary_cards

    validates :mock_true_layer_data,
              :manually_review_all_cases,
              :allow_welsh_translation,
              :enable_ccms_submission,
              :partner_means_assessment,
              :linked_applications,
              :cya_summary_cards,
              presence: true
  end
end
