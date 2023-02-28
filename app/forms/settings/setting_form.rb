module Settings
  class SettingForm < BaseForm
    form_for Setting

    attr_accessor(*::Setting::ATTRIBUTES)

    validates_presence_of(*::Setting::ATTRIBUTES)
  end
end
