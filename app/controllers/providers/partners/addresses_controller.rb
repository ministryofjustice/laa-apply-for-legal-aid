module Providers
  module Partners
    class AddressesController < ProviderBaseController
      prefix_step_with :partner

      def show
        @form = Addresses::PartnerAddressForm.new(model: partner)
      end

      def update
        @form = Addresses::PartnerAddressForm.new(form_params)
        render :show unless save_continue_or_draft(@form)
      end

    private

      def address_attributes
        %i[address_line_one address_line_two city county postcode lookup_postcode lookup_error]
      end

      def form_params
        merge_with_model(partner) do
          params.require(:address).permit(*address_attributes)
        end
      end

      def partner
        legal_aid_application.partner
      end
    end
  end
end
