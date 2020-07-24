class AuthorizationContext
  attr_reader :provider, :controller

  def initialize(provider, controller)
    @provider = provider
    @controller = controller
  end
end
