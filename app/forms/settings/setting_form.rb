module Settings
  class SettingForm
    include BaseForm

    form_for Setting

    attr_accessor :mock_true_layer_data, :allow_non_passported_route, :use_mock_provider_details

    validates :mock_true_layer_data, :allow_non_passported_route, :use_mock_provider_details, presence: true
  end
end
