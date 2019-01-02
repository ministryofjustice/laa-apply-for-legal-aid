# Concern to return true or false if some or none of the attributes have values
# Class method value_attrs should be defined in the calling class to return an array
# of attribute names that should not be tested.
#
module ValueTestable
  extend ActiveSupport::Concern

  class_methods do
    def non_value_attrs
      @non_value_attrs ||= %w[id legal_aid_application_id created_at updated_at]
    end

    def non_value_attrs=(attributes)
      @non_value_attrs = attributes
    end
  end

  def any_value?
    values = value_attrs.map { |attr| __send__(attr) }
    values.any? { |value| value.present? && value != 0 }
  end

  private

  def value_attrs
    attributes.keys - self.class.non_value_attrs
  end
end
