module Settings
  class SettingForm
    include BaseForm

    form_for Setting

    attr_accessor :mock_true_layer_data, :allow_non_passported_route

    validates :mock_true_layer_data, :allow_non_passported_route, presence: true
  end
end
