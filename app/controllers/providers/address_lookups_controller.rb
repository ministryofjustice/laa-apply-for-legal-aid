module Providers
  class AddressLookupsController < BaseController
    include Providers::ApplicationDependable
    include Steppable

    def new
      @form = Applicants::AddressLookupForm.new
    end

    def create
      @form = Applicants::AddressLookupForm.new(form_params)
      @back_step_url = new_providers_legal_aid_application_address_lookups_path

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
        render template: 'providers/address_selections/new'.freeze
      else
        @form = Applicants::AddressForm.new(lookup_postcode: @form.postcode, lookup_error: outcome.errors[:lookup].first)
        render template: 'providers/addresses/new'.freeze
      end
    end
  end
end
