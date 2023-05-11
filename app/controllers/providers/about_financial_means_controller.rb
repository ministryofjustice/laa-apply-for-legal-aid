module Providers
  class AboutFinancialMeansController < ProviderBaseController
    def show
      @name = full_name
      @application = legal_aid_application
      @applicant = legal_aid_application.applicant
    end

  private

    def full_name
      "#{applicant.first_name} #{applicant.last_name}"
    end
  end
end
