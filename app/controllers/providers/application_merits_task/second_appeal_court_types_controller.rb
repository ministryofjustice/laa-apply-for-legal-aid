module Providers
  module ApplicationMeritsTask
    class SecondAppealCourtTypesController < BaseAppealCourtTypesController
    private

      def form
        SecondAppealCourtTypeForm
      end
    end
  end
end
