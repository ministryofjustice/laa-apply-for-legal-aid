module Providers
  class CheckProviderAnswersController < BaseController
    include Providers::ApplicationDependable
    include Steppable

    def index
      @proceeding = legal_aid_application.proceeding_types.first
      @applicant = legal_aid_application.applicant
      @address = @applicant.addresses.first
      legal_aid_application.check_your_answers!
    end

    def confirm
      legal_aid_application.provider_submit!
      CitizenEmailService.new(legal_aid_application).send_email
      flash[:notice] = 'Application completed. An e-mail will be sent to the citizen.'
      redirect_to next_step_url
    end
  end
end
