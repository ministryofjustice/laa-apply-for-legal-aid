module Providers
  module Means
    module CapitalDisregards
      class DiscretionaryController < ProviderBaseController
        def show
          @form = Providers::CapitalDisregards::DiscretionaryForm.new(model: legal_aid_application)
        end

        def update
          @form = Providers::CapitalDisregards::DiscretionaryForm.new(form_params)
          render :show unless save_continue_or_draft(@form)
        end

      private

        def form_params
          params.require(:legal_aid_application).permit(:none_selected, discretionary_disregards: [])
        end
      end
    end
  end
end
