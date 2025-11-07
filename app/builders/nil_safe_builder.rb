module NilSafeBuilder
  def build(obj)
    return nil if obj.nil?

    new(obj)
  end
end
