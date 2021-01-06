module Providers
  class ProviderBaseController < FlowBaseController
    before_action :authenticate_provider!
    before_action :set_cache_buster
    before_action :update_locale
    include ApplicationDependable
    include Draftable
    include Authorizable

    def convert_date_params(model_name)
      # gsub finds ([digit]i) and replaces with _[digit]i
      params[model_name].transform_keys! { |key| key.gsub(/\((\di)\)/, '_\\1') }
    end
  end
end
