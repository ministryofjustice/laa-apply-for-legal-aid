# provides a method to translate the CONTENTS of a model attribute.
#
# e.g. given that record is a LegalAidApplication record with the
# state containing the string "provider_submitted", then
#
#  record.model_t(:state)
#
# will return the translation for the key
# 'activerecord.models.legal_aid_application.attribute_content.state.provider_submitted'
#
# Model attribute translations should be stored in /config/locales/model_attribute_contents.en.yml
#
module TranslatableModelAttribute
  def model_t(attribute)
    model = model_name.i18n_key
    I18n.t(__send__(attribute), scope: [:model_attribute_translations, model, attribute])
  end
end
