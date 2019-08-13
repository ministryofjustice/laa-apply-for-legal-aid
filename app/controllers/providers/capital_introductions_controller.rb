module Providers
  class CapitalIntroductionsController < ProviderBaseController
    def show; end

    def update
      continue_or_draft
    end
  end
end
