module Providers
  class ConfirmDWPNonPassportedApplicationsController < ProviderBaseController
    def show
      render :show
    end

    def update
      go_forward
    end
  end
end
