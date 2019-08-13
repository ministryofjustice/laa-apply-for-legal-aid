module Providers
  class LimitationsController < ProviderBaseController
    def update
      continue_or_draft
    end
  end
end
