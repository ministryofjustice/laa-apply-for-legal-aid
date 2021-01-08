module Settings
  class SettingForm
    include BaseForm

    form_for Setting

    attr_accessor :mock_true_layer_data,
                  :manually_review_all_cases,
                  :allow_welsh_translation,
                  :allow_cash_payment,
                  :allow_multiple_proceedings

    validates :mock_true_layer_data,
              :manually_review_all_cases,
              :allow_welsh_translation,
              :allow_cash_payment,
              :allow_multiple_proceedings,
              presence: true
  end
end
