module Providers
  module Means
    class PaymentsToReviewController < ProviderBaseController
      def show
        @form = Providers::DiscretionaryDisregardsForm.new(model: discretionary_disregards)
      end

      def update
        @form = Providers::DiscretionaryDisregardsForm.new(form_params)
        render :show unless save_continue_or_draft(@form)
      end

    private

      def discretionary_disregards
        @discretionary_disregards ||= legal_aid_application.discretionary_disregards || legal_aid_application.create_discretionary_disregards!
      end

      def form_params
        merge_with_model(discretionary_disregards) do
          attrs = Providers::DiscretionaryDisregardsForm::CHECK_BOXES_ATTRIBUTES
          params[:discretionary_disregards].permit(*attrs)
        end
      end
    end
  end
end
