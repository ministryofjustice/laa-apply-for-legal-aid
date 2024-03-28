module Providers
  module HomeAddress
    class AddressesController < ProviderBaseController
      prefix_step_with :home
      def show
        @form = Addresses::AddressForm.new(model: address)
      end

      def update
        @form = Addresses::AddressForm.new(form_params)
        render :show unless save_continue_or_draft(@form)
      end

    private

      def build_address
        Address.new(
          applicant:,
          location: "home",
          country: "GBR",
        )
      end

      def address_attributes
        %i[address_line_one address_line_two city county postcode lookup_postcode lookup_error]
      end

      def form_params
        merge_with_model(address) do
          params.require(:address).permit(*address_attributes).merge(location: "home")
        end
      end

      def address
        @address ||= current_uk_home_address || build_address
      end

      def current_uk_home_address
        return nil unless applicant.home_address && applicant.home_address.country == "GBR"

        applicant.home_address
      end
    end
  end
end
