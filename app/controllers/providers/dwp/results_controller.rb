module Providers
  module DWP
    class ResultsController < ProviderBaseController
      prefix_step_with :dwp

      def show; end

      def update
        go_forward
      end
    end
  end
end
