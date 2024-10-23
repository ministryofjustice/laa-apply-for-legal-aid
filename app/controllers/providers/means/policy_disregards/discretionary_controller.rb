module Providers
  module Means
    module PolicyDisregards
      class DiscretionaryController < ProviderBaseController
        def show
          @form = Providers::PolicyDisregards::DiscretionaryForm.new(model: legal_aid_application)
        end

        def update
          @form = Providers::PolicyDisregards::DiscretionaryForm.new(form_params)
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
