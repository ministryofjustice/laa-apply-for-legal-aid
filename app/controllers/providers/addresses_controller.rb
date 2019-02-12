module Providers
  class AddressesController < ProviderBaseController
    include ApplicationDependable
    include Flowable
    include Draftable

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

    def address_params
      params.require(:address).permit(*address_attributes)
    end

    def form_params
      address_params.merge(model: address)
    end

    def address
      applicant.address || applicant.build_address
    end
  end
end
