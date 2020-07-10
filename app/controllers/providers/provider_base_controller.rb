module Providers
  class ProviderBaseController < FlowBaseController
    before_action :authenticate_provider!
    before_action :set_cache_buster
    include ApplicationDependable
    include Draftable
    include Authorizable

    def pre_dwp_check?
      false
    end
  end
end
