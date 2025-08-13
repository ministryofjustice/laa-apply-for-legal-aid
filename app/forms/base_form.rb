class BaseForm
  include ActiveModel::Model
  include ActiveModel::Validations::Callbacks
  include ActiveSupport::Callbacks

  define_callbacks :save, :validation

  attr_writer :model

  class << self
    def form_for(klass)
      @model_class = klass
    end

    def model_class
      # If there are any errors on the form, in order to get the I18n keys, the ActiveModel::Naming module calls #model_name on the form **and all it's ancestors**,
      # so it will get called on this Base class. In this case, we just return our class - it won't get used and does no harm.
      #
      return self if name.match?(/Base.*Form/)

      @model_class || raise("Model class must be defined. Use: `form_for Class`")
    end

    def model_name
      ActiveModel::Name.new(self, nil, model_class.to_s)
    end

    # Overrides `attr_accessor` to track which attributes have been assigned within the form
    def attr_accessor(*symbols)
      locally_assigned << symbols
      locally_assigned.flatten!
      super
    end

    def locally_assigned
      @locally_assigned ||= []
    end

    # :nocov:
    # TODO: Check after linked and copy cases re-implementation
    #  if this method is still needed
    def normalizes(name, with:)
      before_validation do
        send(:"#{name}=", with.call(send(name)))
      end
    end
    # :nocov:
  end

  def initialize(*args)
    super
    set_instance_variables_for_attributes_if_not_set_but_in_model(
      attrs: self.class.locally_assigned,
      model_attributes: model&.attributes,
    )
  end

  def model
    @model ||= self.class.model_class.new
  end

  def save
    run_callbacks :validation do
      return false unless valid?
    end

    return true if assignable_attributes.empty?

    run_callbacks :save do
      model.attributes = clean_attributes(assignable_attributes)
      model.save!(validate: false)
    end
  end
  alias_method :save!, :save

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

  def squish_whitespaces(*attribute_names)
    attribute_names.each do |attr_name|
      attributes[attr_name.to_s]&.squish!
    end
  end

  def save_as_draft
    @draft = true
    set_blanks_to_nil
    save! unless all_entries_blank?
  end

  def draft?
    @draft
  end

  def has_partner_with_no_contrary_interest?
    model.applicant&.has_partner_with_no_contrary_interest?
  end

private

  def clean_attributes(hash)
    hash.each_with_object({}) do |(k, v), new_hash|
      new_hash[k] = k.to_sym.in?(attributes_to_clean) ? v.to_s.tr("£,", "") : v
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

  def error_key(key_name)
    return "#{key_name}_with_partner" if has_partner_with_no_contrary_interest?

    key_name
  end
end
