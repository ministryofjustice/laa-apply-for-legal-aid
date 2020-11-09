class ProviderAfterLoginService
  def self.call(provider)
    new(provider).call
  end

  def initialize(provider)
    @provider = provider
  end

  def call
    @provider.update!(invalid_login_details: nil)
    if @provider.ccms_apply_role?
      check_provider_details_api
    else
      @provider.update!(invalid_login_details: 'role')
    end
  end

  private

  def check_provider_details_api
    if @provider.newly_created_by_devise?
      call_provider_details_api
    else
      @provider.update_details
    end
  end

  def call_provider_details_api
    ProviderDetailsCreator.call(@provider)
    @provider.clear_invalid_login!
  rescue ProviderDetailsRetriever::ApiRecordNotFoundError
    @provider.update!(invalid_login_details: 'api_details_user_not_found')
  rescue ProviderDetailsRetriever::ApiError
    @provider.update!(invalid_login_details: 'provider_details_api_error')
  end
end
