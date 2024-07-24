module Providers
  class SearchExistingApplicationsController < ProviderBaseController
    legal_aid_application_not_required!

    def new; end
  end
end
