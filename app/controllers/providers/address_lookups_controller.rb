module Providers
  class AddressLookupsController < BaseController
    include ApplicationDependable
    include Flowable

    def show
      @form = Addresses::AddressLookupForm.new
    end

    def update
      @form = Addresses::AddressLookupForm.new(form_params)

      if @form.save
        go_forward
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
