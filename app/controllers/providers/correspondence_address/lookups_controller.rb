module Providers
  module CorrespondenceAddress
    class LookupsController < ProviderBaseController
      prefix_step_with :correspondence_address

      def show
        @form = Addresses::AddressLookupForm.new(model: address)
      end

      def update
        @form = Addresses::AddressLookupForm.new(form_params)
        render :show unless save_continue_or_draft(@form)
      end

    private

      def form_params
        merge_with_model(address) do
          params.require(:address_lookup).permit(:postcode, :building_number_name)
        end
      end

      def address
        applicant.address || applicant.build_address(location: "correspondence", country_code: "GBR", country_name: "United Kingdom")
      end
    end
  end
end
