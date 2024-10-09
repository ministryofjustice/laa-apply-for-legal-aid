module Providers
  module Means
    class PaymentsToReviewController < ProviderBaseController
      def show
        @form = Providers::DiscretionaryDisregardsForm.new(model: discretionary_disregards)
      end

      def update; end

    private

      def discretionary_disregards
        @discretionary_disregards ||= legal_aid_application.discretionary_disregards || legal_aid_application.create_discretionary_disregards!
      end
    end
  end
end
