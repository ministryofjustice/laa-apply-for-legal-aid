module Providers
  class SubmittedApplicationsController < ProviderBaseController
    include TransactionTypeSettable

    authorize_with_policy_method :show_submitted_application?
    helper_method :display_employment_income?
    helper_method :link_banner_display

    def show
      @source_application = @legal_aid_application.copy_case? ? LegalAidApplication.find(legal_aid_application.copy_case_id) : @legal_aid_application
      @read_only = true
      @show_datastore_id = [
        Setting.enable_datastore_submission?,
        @legal_aid_application.datastore_id,
        HostEnv.not_production?,
      ].all?
    end
  end
end
