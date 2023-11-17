class NumericalityPartnerOptionalValidator < ActiveModel::Validations::NumericalityValidator
  def validate_each(record, attr_name, value)
    clean_value = clean_numeric_value(value)
    super(record, attr_name, clean_value) # this requires the actual attribute symbol, e.g. :cash

    replace_error_with_partner(record, attr_name) if any_errors_for?(record, attr_name) && use_partner_labels?(record)
  end

  def clean_numeric_value(value)
    CurrencyCleaner.new(value).call
  end

private

  def any_errors_for?(record, attr_name)
    record.errors[attr_name].any?
  end

  def use_partner_labels?(record)
    return false if options[:partner_labels].blank?

    record.send(options[:partner_labels])
  end

  def replace_error_with_partner(record, attr_name)
    original_error_type = record.errors.where(attr_name).first.type
    partner_error_type = "#{original_error_type}_with_partner".to_sym

    record.errors.delete(attr_name) # delete original
    record.errors.add(attr_name, partner_error_type) # replace with partner version
  end
end
