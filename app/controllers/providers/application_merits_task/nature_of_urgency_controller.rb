module Providers
  module ApplicationMeritsTask
    class NatureOfUrgencyController < ProviderBaseController
      def show
        @form = ApplicationMeritsTask::NatureOfUrgencyForm.new(model: urgency)
      end

      def update; end

    private

      def urgency
        legal_aid_application.urgency
      end
    end
  end
end
