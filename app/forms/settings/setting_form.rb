module Settings
  class SettingForm
    include BaseForm

    form_for Setting

    attr_accessor :mock_true_layer_data

    validates :mock_true_layer_data, presence: true
  end
end
