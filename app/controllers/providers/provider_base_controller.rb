module Providers
  class ProviderBaseController < FlowBaseController
    before_action :authenticate_provider!
    before_action :set_cache_buster
    before_action :update_locale
    include ApplicationDependable
    include ApplicationTrackable
    include Draftable
    include Authorizable

  private

    def display_employment_income?
      @legal_aid_application.cfe_result.version >= 4 &&
        @legal_aid_application.cfe_result.jobs?
    end

    def link_banner_display
      count = LinkedApplication.where(lead_application: @legal_aid_application).count
      return if count.zero?
      return I18n.t("providers.submitted_applications.show.link_banner_many", count:) if count > 1

      I18n.t("providers.submitted_applications.show.link_banner_one")
    end
  end
end
