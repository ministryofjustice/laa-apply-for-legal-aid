module Providers
  class ProviderBaseController < FlowBaseController
    before_action :authenticate_provider!
    before_action :set_cache_buster
    before_action :update_locale
    include ApplicationDependable
    include Draftable
    include Authorizable

  private

    def display_employment_income?
      Setting.enable_employed_journey? &&
        @legal_aid_application.provider.employment_permissions? &&
        @legal_aid_application.cfe_result.version >= 4 &&
        @legal_aid_application.cfe_result.jobs?
    end
  end
end
