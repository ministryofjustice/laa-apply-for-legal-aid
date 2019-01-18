class ApplicationPolicy
  attr_reader :provider, :record

  def initialize(provider, record)
    raise Pundit::NotAuthorizedError, 'must be logged in' unless provider

    @provider = provider
    @record = record
  end
end
