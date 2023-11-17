class PresencePartnerOptionalValidator < ActiveModel::Validations::PresenceValidator
  def validate_each(record, attr_name, value)
    key_name = record.send(options[:partner_labels]) ? :blank_with_partner : :blank
    record.errors.add(attr_name, key_name, **options) if value.blank?
  end
end
