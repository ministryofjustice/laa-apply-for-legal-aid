module Providers
  module Means
    module CapitalDisregards
      class MandatoryController < ProviderBaseController
        prefix_step_with :capital_disregards

        def show
          @form = Providers::Means::CapitalDisregards::MandatoryForm.new(model: legal_aid_application)
        end

        def update
          @form = Providers::Means::CapitalDisregards::MandatoryForm.new(form_params)
          render :show unless save_continue_or_draft(@form)
        end

      private

        def form_params
          merge_with_model(legal_aid_application) do
            params.require(:providers_means_capital_disregards_mandatory_form)
                  .permit(:none_selected, mandatory_capital_disregards: [])
                  .merge(legal_aid_application:)
          end
        end
      end
    end
  end
end
