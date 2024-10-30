module Providers
  module Means
    module CapitalDisregards
      class DiscretionaryController < ProviderBaseController
        prefix_step_with :capital_disregards

        def show
          @form = DiscretionaryForm.new(model: legal_aid_application)
        end

        def update
          @form = DiscretionaryForm.new(form_params)
          render :show unless save_continue_or_draft(@form)
        end

      private

        def form_params
          params
            .require(:providers_means_capital_disregards_discretionary_form)
            .permit(:none_selected, discretionary_capital_disregards: [])
            .merge(legal_aid_application:)
        end
      end
    end
  end
end
