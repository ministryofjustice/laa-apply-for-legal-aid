module Providers
  class UsedDelegatedFunctionsController < ProviderBaseController
    def show
      @form = LegalAidApplications::UsedDelegatedFunctionsForm.new(model: legal_aid_application)
    end

    def update; end
  end
end
