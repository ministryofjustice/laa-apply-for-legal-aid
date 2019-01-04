module Providers
  class AboutTheFinancialAssessmentsController < BaseController
    include ApplicationDependable
    include Steppable

    def show; end

    def submit
      legal_aid_application.provider_submit!
      CitizenEmailService.new(legal_aid_application).send_email
    end
  end
end
