module Providers
  class AddressLookupsController < BaseController
    include Providers::ApplicationDependable
    include Steppable

    def show
      @form = Addresses::AddressLookupForm.new
    end

    def update
      @form = Addresses::AddressLookupForm.new(form_params)
      @back_step_url = providers_legal_aid_application_address_lookup_path

      if @form.save
        redirect_to next_step_url
      else
        render :show
      end
    end

    private

    def form_params
      params.require(:address_lookup).permit(:postcode).merge(model: address)
    end

    def address
      applicant.address || applicant.build_address
    end
  end
end
