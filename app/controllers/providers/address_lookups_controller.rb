module Providers
  class AddressLookupsController < BaseController
    include Providers::ApplicantDependable

    def new
      @form = Applicants::AddressLookupForm.new
    end

    def create
      @form = Applicants::AddressLookupForm.new(form_params)

      if @form.valid?
        perform_and_handle_lookup
      else
        render :new
      end
    end

    private

    def form_params
      params.require(:address_lookup).permit(:postcode)
    end

    def perform_and_handle_lookup
      outcome = AddressLookupService.call(@form.postcode)

      if outcome.success?
        @addresses = outcome.result
        @form = Applicants::AddressSelectionForm.new(postcode: @form.postcode)
        render template: 'providers/address_selections/new'
      else
        @form = Applicants::AddressForm.new(lookup_postcode: @form.postcode, lookup_error: outcome.errors[:lookup].first)
        render template: 'providers/addresses/new'
      end
    end
  end
end
