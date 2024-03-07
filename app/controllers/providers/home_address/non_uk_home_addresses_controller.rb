module Providers
  module HomeAddress
    class NonUkHomeAddressesController < ProviderBaseController
      def show
        @form = Addresses::NonUkHomeAddressForm.new(model: non_uk_home_address)
      end

      def update
        @form = Addresses::NonUkHomeAddressForm.new(form_params)
        render :show unless save_continue_or_draft(@form)
      end

    private

      def non_uk_home_address
        applicant.address || applicant.build_address(location: "home")
      end

      def form_params
        merge_with_model(non_uk_home_address) do
          params.require(:non_uk_home_address).permit(
            :country, :address_line_one, :address_line_two, :city, :county
          )
        end
      end
    end
  end
end
