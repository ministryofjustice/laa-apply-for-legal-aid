class BaseJsonBuilder
  # Helper to return nil instead of an instance with a nil object. Use instead of new
  def self.build(obj)
    return nil if obj.nil?

    new(obj)
  end

  def initialize(object)
    @object = object
  end

  attr_reader :object

  # :nocov:
  def attribute_hash
    raise NotImplementedError, "#{self.class} must implement #attribute_hash"
  end
  # :nocov:

  def as_json(*)
    normalize_json(attribute_hash)
  end

private

  # Use to apply any custom rules for parsing values
  # - Enforce BigDecimal to "floating point as string" to avoid unexpected serialization issues from Rails version or JSON changes
  def normalize_json(value)
    case value
    when BigDecimal
      value.to_s("F")

    when Hash
      value.transform_values { |v| normalize_json(v) }

    when Array
      value.map { |v| normalize_json(v) }

    else
      value
    end
  end

  # :nocov:
  # delegate all missing method calls to the object being serialized
  def method_missing(method, ...)
    if object.respond_to?(method)
      object.public_send(method, ...)
    else
      super
    end
  end

  def respond_to_missing?(method, include_private = false)
    object.respond_to?(method, include_private) || super
  end
  # :nocov:
end
