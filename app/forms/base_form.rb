require_relative 'concerns/date_field_builder'

# Add common methods to forms.
# Usage:
#   Add the following to the form:
#
#       include BaseForm
#       form_for <ModelClass>
#
module BaseForm
  attr_writer :model

  def self.included(base)
    super
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
      @model_class || raise('Model class must be defined. Use: `form_for Class`')
    end

    def model_name
      ActiveModel::Name.new(self, nil, model_class.to_s)
    end

    # Overrides `attr_accessor` to track which attributes have been assigned within the form
    def attr_accessor(*symbols)
      locally_assigned << symbols
      locally_assigned.flatten!
      super(*symbols)
    end

    def locally_assigned
      @locally_assigned ||= []
    end
  end

  module InstanceMethods
    # Allows a form to be initiated with an existing model instance, and for the values in the
    # model to be passed to the form.
    #
    #   some_model = SomeModel.find(params[:id])
    #   some_model.foo = :bar
    #   form = SomeForm.new(model: some_model)
    #   form.foo == :bar
    #
    # Assuming SomeForm definition includes `attr_accessor :foo`
    #
    def initialize(*args)
      super
      set_instance_variables_for_attributes_if_not_set_but_in_model(
        attrs: self.class.locally_assigned,
        model_attributes: model&.attributes
      )
    end

    def model
      @model ||= self.class.model_class.new
    end

    def save
      return false unless valid?

      return true if assignable_attributes.empty?

      model.attributes = clean_attributes(assignable_attributes)
      model.save(validate: false)
    end

    # List of form attributes not to be passed to model
    def exclude_from_model
      []
    end

    def attributes_to_clean
      []
    end

    def assignable_attributes
      exclude_attrs = exclude_from_model + [:model]
      attributes.deep_stringify_keys!.except(*exclude_attrs.map(&:to_s))
    end

    def attributes
      @attributes ||= {}
    end

    def save_as_draft
      @draft = true
      set_blanks_to_nil
      save unless all_entries_blank?
    end

    def draft?
      @draft
    end

    private

    def clean_attributes(hash)
      hash.each_with_object({}) do |(k, v), new_hash|
        new_hash[k] = k.to_sym.in?(attributes_to_clean) ? v.to_s.tr('£,', '') : v
      end
    end

    def set_blanks_to_nil
      self.class.locally_assigned.each do |attr|
        attributes[attr.to_s] = nil if attributes[attr.to_s].blank?
      end
    end

    def all_entries_blank?
      attributes_set_by_form.values.all?(&:blank?)
    end

    def attributes_set_by_form
      attributes.slice(*self.class.locally_assigned.map(&:to_s))
    end

    # Over-riding ActiveModel::AttributeAssignment method to store attributes as they are built
    def _assign_attribute(key, value)
      attributes[key.to_s] = value
      super
    end

    def set_instance_variables_for_attributes_if_not_set_but_in_model(attrs:, model_attributes:)
      return if model_attributes.blank?

      model_attributes.stringify_keys!

      attrs.map(&:to_s).each do |method|
        model_value = model_attributes[method]
        instance_variable_set(:"@#{method}", model_value) if !model_value.nil? && attributes[method].nil?
      end
    end
  end
end
