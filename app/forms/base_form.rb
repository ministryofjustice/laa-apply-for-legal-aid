# Add common methods to forms.
# Usage:
#   Add the following to the form:
#
#       include BaseForm
#

module BaseForm
  attr_writer :model

  def self.included(base)
    base.include(ActiveModel::Model)
    base.include(ActiveModel::Validations::Callbacks)
    base.extend(ClassMethods)
    base.include(InstanceMethods)
  end

  module ClassMethods
    def form_for(klass)
      @model_class = klass
    end

    def model_class
      @model_class || raise('Model class must be defined. Use: `form_for ClassName`')
    end

    def model_name
      ActiveModel::Name.new(self, nil, model_class.to_s)
    end
  end

  module InstanceMethods
    def model
      @model ||= self.class.model_class.new
    end

    def save
      return false unless valid?
      model.attributes = assignable_attributes
      model.save(validate: false)
    end

    # List of form attributes not to be passed to model
    def exclude_from_model
      []
    end

    def assignable_attributes
      exclude_attrs = exclude_from_model + [:model]
      attributes.except(*exclude_attrs.map(&:to_s))
    end

    def attributes
      @attributes ||= {}
    end

    private

    # Over-riding ActiveModel::AttributeAssignment method to store attributes as they are built
    # rubocop:disable Naming/UncommunicativeMethodParamName
    def _assign_attribute(k, v)
      attributes[k] = v
      super
    end
    # rubocop:enable Naming/UncommunicativeMethodParamName
  end
end
