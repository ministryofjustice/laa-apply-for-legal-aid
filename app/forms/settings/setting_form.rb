module Settings
  class SettingForm
    include BaseForm

    form_for Setting

    attr_accessor :mock_true_layer_data,
                  :allow_non_passported_route,
                  :manually_review_all_cases,
                  :use_new_student_loan

    validates :mock_true_layer_data,
              :allow_non_passported_route,
              :manually_review_all_cases,
              :use_new_student_loan,
              presence: true
  end
end
