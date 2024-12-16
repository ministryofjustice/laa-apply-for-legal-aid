module Providers
  module ApplicationMeritsTask
    class FirstAppealCourtTypesController < BaseAppealCourtTypesController
    private

      def form
        FirstAppealCourtTypeForm
      end
    end
  end
end
