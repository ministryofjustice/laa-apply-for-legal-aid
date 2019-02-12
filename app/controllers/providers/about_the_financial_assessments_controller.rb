module Providers
  class AboutTheFinancialAssessmentsController < BaseController
    include ApplicationDependable
    include Flowable
    include Draftable

    def show; end

    def submit
      return continue_or_draft if draft_selected?
      return if legal_aid_application.provider_submitted?

      legal_aid_application.provider_submit!
      CitizenEmailService.new(legal_aid_application).send_email
    end
  end
end
