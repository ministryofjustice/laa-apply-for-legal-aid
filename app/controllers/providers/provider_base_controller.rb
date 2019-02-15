module Providers
  class ProviderBaseController < BaseController
    before_action :authenticate_provider!
    before_action :set_cache_buster
    include Pundit
    include ApplicationDependable
    include Flowable
    include Draftable

    rescue_from Pundit::NotAuthorizedError, with: :provider_not_authorized

    # This stops the browser caching these pages.
    # This is done so that someone can't use the Back button to return to a users pages
    # after they have logged out. There is a cost to page load speeds as a result
    def set_cache_buster
      response.headers['Cache-Control'] = 'no-cache, no-store, max-age=0, must-revalidate'
      response.headers['Pragma'] = 'no-cache'
      response.headers['Expires'] = 'Fri, 01 Jan 1990 00:00:00 GMT'
    end

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
