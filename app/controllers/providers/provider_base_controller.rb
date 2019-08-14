module Providers
  class ProviderBaseController < BaseController
    before_action :authenticate_provider!
    before_action :set_cache_buster
    include ApplicationDependable
    include Draftable
    include Authorizable

    def pundit_user
      current_provider
    end

    private

    def provider_not_authorized
      respond_to do |format|
        format.html { render 'shared/access_denied', status: :forbidden }
      end
    end
  end
end
