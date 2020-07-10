module Providers
  class EndOfApplicationsController < ProviderBaseController
    authorize_with_policy_method :show_submitted_application?

    def show; end

    def update
      # Behaves like save as draft - but doesn't set the application to draft
      draft_selected? ? redirect_to(draft_target_endpoint) : go_forward
    end
  end
end
