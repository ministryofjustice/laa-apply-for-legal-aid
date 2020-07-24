class ApplicationPolicy
  attr_reader :provider, :record

  def initialize(authorization_context, record)
    @provider = authorization_context.provider
    @controller = authorization_context.controller
    @record = record
    raise Pundit::NotAuthorizedError, 'must be logged in' unless @provider
  end
end
