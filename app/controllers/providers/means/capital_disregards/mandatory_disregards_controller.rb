module Providers
  module Means
    module CapitalDisregards
      class MandatoryDisregardsController < ProviderBaseController
        def show
          @form = Providers::Means::CapitalDisregards::MandatoryDisregardsForm.new(model: legal_aid_application)
        end

        def update
          @form = Providers::Means::CapitalDisregards::MandatoryDisregardsForm.new(form_params)
          render :show unless save_continue_or_draft(@form)
        end

      private

        def form_params
          merge_with_model(legal_aid_application) do
            params.require(:legal_aid_application)
                  .permit(mandatory_capital_disregards: [])
                  .merge(none_selected: params[:legal_aid_application][:none_selected])
          end
        end
      end
    end
  end
end
