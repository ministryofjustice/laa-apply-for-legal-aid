module Providers
  module Partners
    class AddressLookupsController < ProviderBaseController
      prefix_step_with :partner

      def show
        @form = Addresses::PartnerAddressLookupForm.new(model: partner)
      end

      def update
        @form = Addresses::PartnerAddressLookupForm.new(form_params)
        render :show unless save_continue_or_draft(@form)
      end

    private

      def form_params
        merge_with_model(partner) do
          params.require(:address_lookup).permit(:postcode)
        end
      end

      def partner
        legal_aid_application.partner
      end
    end
  end
end
