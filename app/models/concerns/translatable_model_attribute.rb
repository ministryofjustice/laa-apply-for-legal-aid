# provides a method to translate the values of an enum or field with a fixed number of values like state
# machine states.
#
# e.g. given that application is a LegalAidApplication record with the
# state containing the string "provider_submitted", then
#
#  application.enum_t(:state)
#
# will return the translation for the key
# 'en.model_attribute_translations.legal_aid_application.state.provider_submitted'
#
# Enum translations should be stored in /config/locales/en/model_enum_translations.yml
#
module TranslatableModelAttribute
  extend ActiveSupport::Concern

  def enum_t(attribute)
    model = model_name.i18n_key
    I18n.t(__send__(attribute), scope: [:model_enum_translations, model, attribute])
  end

  class_methods do
    # This method generates a radio button for each option in an enum
    # For example, if the form object is a `Feedback` instance which has the
    # `satisfaction` enum attribute:
    #     <%= Feedback.enum_radio_buttons(form, :satisfaction) %>
    # To reverse the order:
    #     <%= Feedback.enum_radio_buttons(form, :satisfaction, order: :reverse) %>
    def enum_radio_buttons(form, attribute, order: :normal, args: nil)
      collection = enum_ts(attribute).map do |option, translation|
        OpenStruct.new(name: option.to_s, label: translation)
      end
      collection.reverse! if order == :reverse
      form.govuk_collection_radio_buttons(attribute, collection, :name, :label, **args)
    end

    def enum_ts(attribute)
      enums = __send__(attribute.to_s.pluralize)
      enum_ts_cache[attribute.to_sym] ||= enums.keys.each_with_object({}) do |value, hash|
        hash[value.to_sym] = I18n.t(value, scope: [:model_enum_translations, model_name.i18n_key, attribute])
      end
    end

    def enum_ts_cache
      @enum_ts_cache ||= {}
    end
  end
end
