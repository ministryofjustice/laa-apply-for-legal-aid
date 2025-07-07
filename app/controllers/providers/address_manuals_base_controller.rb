module Providers
  class AddressManualsBaseController < ProviderBaseController
    def show
      @form = Addresses::AddressForm.new(model: address)
    end

    def update
      untrack!(:check_provider_answers)

      @form = Addresses::AddressForm.new(form_params)
      render :show unless save_continue_or_draft(@form)
    end

  private

    def address_attributes
      %i[address_line_one address_line_two city county postcode lookup_postcode lookup_error]
    end

    def form_params
      merge_with_model(address) do
        params.expect(address: [*address_attributes]).merge(location:)
      end
    end
  end
end
