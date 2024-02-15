module Settings
  class SettingForm < BaseForm
    form_for Setting

    attr_accessor :mock_true_layer_data,
                  :manually_review_all_cases,
                  :allow_welsh_translation,
                  :enable_ccms_submission,
                  :partner_means_assessment,
                  :linked_applications,
                  :collect_hmrc_data,
                  :home_address

    validates :mock_true_layer_data,
              :manually_review_all_cases,
              :allow_welsh_translation,
              :enable_ccms_submission,
              :partner_means_assessment,
              :linked_applications,
              :collect_hmrc_data,
              :home_address,
              presence: true
  end
end
