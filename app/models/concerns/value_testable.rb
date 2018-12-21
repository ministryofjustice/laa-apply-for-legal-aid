# Concern to return true or false if some or none of the attributes have values
# Class method value_attrs should be defined in the calling class to return an array
# of attribute names that should not be tested.
#
module ValueTestable
  extend ActiveSupport::Concern

  def any_value?
    values_present = value_attrs.map { |attr| __send__(attr).present? && __send__(attr) != 0 }
    values_present.any?
  end

  private

  def value_attrs
    attributes.keys - self.class.non_value_attrs
  end
end
