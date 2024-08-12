module Providers
  module ProceedingsSCA
    class ConfirmDeleteCoreProceedingsController < ProviderBaseController
      prefix_step_with :proceedings_sca

      def show
        proceeding
      end

    private

      def proceeding
        @proceeding = Proceeding.find(params["proceeding_id"])
      end
    end
  end
end
