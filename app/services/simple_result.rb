class SimpleResult
  attr_reader :value, :error

  def initialize(value: nil, error: nil)
    @value = value
    @error = error
  end
end
