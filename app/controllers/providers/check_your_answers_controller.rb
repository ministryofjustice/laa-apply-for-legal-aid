module Providers
  class CheckYourAnswersController < BaseController
    include Providers::ApplicationDependable

    def index; end

    def confirm
      CitizenEmailService.new(legal_aid_application).send_email
      flash[:notice] = 'Application completed. An e-mail will be sent to the citizen.'
      redirect_to providers_legal_aid_applications_path
    end
  end
end
