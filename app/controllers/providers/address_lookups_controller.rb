module Providers
  class AddressLookupsController < ProviderBaseController
    before_action :authorize_legal_aid_application

    def show
      @form = Addresses::AddressLookupForm.new(model: address)
    end

    def update
      @form = Addresses::AddressLookupForm.new(form_params)
      render :show unless save_continue_or_draft(@form)
    end

    private

    def form_params
      params.require(:address_lookup).permit(:postcode).merge(model: address)
    end

    def address
      applicant.address || applicant.build_address
    end

    def authorize_legal_aid_application
      authorize @legal_aid_application
    end
  end
end
