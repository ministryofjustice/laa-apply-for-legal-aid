module Providers
  class ProviderBaseController < FlowBaseController
    before_action :authenticate_provider!
    before_action :set_cache_buster
    before_action :update_locale
    include Appointable
    include ApplicationDependable
    include Draftable
    include Authorizable
    include Reviewable::Controller

    helper_method :display_hmrc_text?, :back_link_unless

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

    def make_hmrc_call?
      Setting.collect_hmrc_data?
    end
    alias_method :display_hmrc_text?, :make_hmrc_call?
  end
end
