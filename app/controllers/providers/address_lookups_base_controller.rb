module Providers
  class AddressLookupsBaseController < ProviderBaseController
    def show
      @form = Addresses::AddressLookupForm.new(model: address)
      @correspondence_address_choice = legal_aid_application.applicant.correspondence_address_choice
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
  end
end
