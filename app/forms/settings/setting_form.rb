module Settings
  class SettingForm
    include BaseForm

    form_for Setting

    attr_accessor :mock_true_layer_data,
                  :allow_non_passported_route,
                  :manually_review_all_cases

    validates :mock_true_layer_data,
              :allow_non_passported_route,
              :manually_review_all_cases,
              presence: true
  end
end
