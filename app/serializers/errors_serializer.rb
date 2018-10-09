class ErrorsSerializer
  attr_reader :errors

  def initialize(errors)
    @errors = errors
  end

  def as_json(_options = nil)
    errors.details.map { |field, details|
      details.map do |error_details|
        ErrorSerializer.new(field, error_details).as_json
      end
    }.flatten
  end
end
