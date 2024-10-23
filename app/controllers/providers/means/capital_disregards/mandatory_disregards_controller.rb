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
      end
    end
  end
end
