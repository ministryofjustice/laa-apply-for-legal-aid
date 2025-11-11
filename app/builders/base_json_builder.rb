class BaseJsonBuilder
  def initialize(object)
    @object = object
  end

  attr_reader :object

  # :nocov:
  def as_json(*)
    raise NotImplementedError, "#{self.class} must implement #as_json"
  end

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

  # Helper to return nil instead of an instance with a nil object. Use instead of new
  def self.build(obj)
    return nil if obj.nil?

    new(obj)
  end
end
