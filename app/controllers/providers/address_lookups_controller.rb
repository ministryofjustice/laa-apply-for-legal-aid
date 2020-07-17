module Providers
  class AddressLookupsController < ProviderBaseController
    include PreDWPCheckVisible

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
        params.require(:address_lookup).permit(:postcode)
      end
    end

    def address
      applicant.address || applicant.build_address
    end
  end
end
