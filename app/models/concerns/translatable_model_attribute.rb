# provides a method to translate the values of an enum or field with a fixed number of values like state
# machine states.
#
# e.g. given that applicaiton is a LegalAidApplication record with the
# state containing the string "provider_submitted", then
#
#  application.enum_t(:state)
#
# will return the translation for the key
# 'en.model_attribute_translations.legal_aid_application.state.provider_submitted'
#
# Enum translations should be stored in /config/locales/model_enum_translations.en.yml
#
module TranslatableModelAttribute
  def enum_t(attribute)
    model = model_name.i18n_key
    I18n.t(__send__(attribute), scope: [:model_enum_translations, model, attribute])
  end
end
