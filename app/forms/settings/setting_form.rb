module Settings
  class SettingForm
    include BaseForm

    form_for Setting

    attr_accessor :mock_true_layer_data,
                  :manually_review_all_cases,
                  :allow_welsh_translation

    validates :mock_true_layer_data,
              :manually_review_all_cases,
              :allow_welsh_translation,
              presence: true
  end
end
