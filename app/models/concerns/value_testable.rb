# Concern to return true or false if some or none of the attributes have values
# Class method value_attrs should be defined in the calling class to return an array
# of attribute names that should not be tested.
#
module ValueTestable
  def non_value_attrs
    %w[id legal_aid_application_id created_at updated_at]
  end

  def any_value?
    values = value_attrs.map { |attr| __send__(attr) }
    values.any? { |value| value.present? && value != 0 }
  end

  private

  def value_attrs
    attributes.keys - non_value_attrs
  end
end
