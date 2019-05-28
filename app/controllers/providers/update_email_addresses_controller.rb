module Providers
  class UpdateEmailAddressesController < ProviderBaseController
    def show
      @applicant = legal_aid_application.applicant
    end
  end
end
