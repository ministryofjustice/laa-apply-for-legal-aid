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
                  :home_address,
                  :special_childrens_act

    validates :mock_true_layer_data,
              :manually_review_all_cases,
              :allow_welsh_translation,
              :enable_ccms_submission,
              :partner_means_assessment,
              :linked_applications,
              :collect_hmrc_data,
              :home_address,
              :special_childrens_act,
              presence: true
  end
end
