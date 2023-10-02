module Settings
  class SettingForm < BaseForm
    form_for Setting

    attr_accessor :mock_true_layer_data,
                  :manually_review_all_cases,
                  :allow_welsh_translation,
                  :enable_ccms_submission,
                  :partner_means_assessment,
                  :opponent_organisations,
                  :linked_applications

    validates :mock_true_layer_data,
              :manually_review_all_cases,
              :allow_welsh_translation,
              :enable_ccms_submission,
              :partner_means_assessment,
              :opponent_organisations,
              :linked_applications,
              presence: true
  end
end
