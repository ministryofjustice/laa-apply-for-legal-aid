module Providers
  class CheckYourAnswersController < BaseController
    include Providers::ApplicationDependable

    def index; end

    def confirm
      legal_aid_application.provider_submit!
      CitizenEmailService.new(legal_aid_application).send_email
    end
  end
end
