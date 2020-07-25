module Providers
  class AddressesController < ProviderBaseController
    include PreDWPCheckVisible

    def show
      @form = Addresses::AddressForm.new(model: address)
    end

    def update
      @form = Addresses::AddressForm.new(form_params)
      render :show unless save_continue_or_draft(@form)
    end

    private

    def address_attributes
      %i[address_line_one address_line_two city county postcode lookup_postcode lookup_error]
    end

    def form_params
      merge_with_model(address) do
        params.require(:address).permit(*address_attributes)
      end
    end

    def address
      applicant.address || applicant.build_address
    end
  end
end
