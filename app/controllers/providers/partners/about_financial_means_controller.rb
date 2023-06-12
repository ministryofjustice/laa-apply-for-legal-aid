module Providers
  module Partners
    class AboutFinancialMeansController < ProviderBaseController
      prefix_step_with :partner

      def update
        continue_or_draft
      end
    end
  end
end
