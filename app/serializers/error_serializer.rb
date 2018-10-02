class ErrorSerializer
  def initialize(field, details)
    @field = field
    @details = details
  end

  def as_json(_options = nil)
    {
      field: field,
      code: code
    }
  end

  private

  attr_reader :details

  def field
    # TODO: might need to be mapped to a different name
    # if its being exposed with a different one.
    @field.to_s
  end

  def code
    I18n.t(
      details[:error],
      scope: %i[api errors codes],
      default: details[:error].to_s
    )
  end
end
