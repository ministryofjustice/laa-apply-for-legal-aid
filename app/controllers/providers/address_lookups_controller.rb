module Providers
  class AddressLookupsController < ProviderBaseController
    include ApplicationDependable
    include Flowable

    before_action :authorize_legal_aid_application

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

    def authorize_legal_aid_application
      authorize @legal_aid_application
    end
  end
end
