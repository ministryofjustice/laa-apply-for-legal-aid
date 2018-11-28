module Providers
  class AddressSelectionsController < BaseController
    include Providers::ApplicationDependable
    include Providers::Steppable

    def show
      return redirect_to back_step_url unless current_postcode

      outcome = AddressLookupService.call(current_postcode)
      if outcome.success?
        @addresses = outcome.result
        @form = Applicants::AddressSelectionForm.new(postcode: current_postcode, lookup_id: current_lookup_id)
      else
        @form = Applicants::AddressForm.new(lookup_postcode: current_postcode, lookup_error: outcome.errors[:lookup].first)
        render template: 'providers/addresses/show'.freeze
      end
    end

    def update
      @addresses = build_addresses_from_form_data
      @form = Applicants::AddressSelectionForm.new(form_params.merge(addresses: @addresses))

      if @form.save
        redirect_to next_step_url
      else
        render :show
      end
    end

    private

    def current_postcode
      applicant.address&.postcode
    end

    def current_lookup_id
      applicant.address&.lookup_id
    end

    def permitted_params
      params.require(:address_selection).permit(:lookup_id, :postcode)
    end

    def form_params
      permitted_params.merge(applicant_id: applicant.id)
    end

    def address_list_params
      params.require(:address_selection).permit(list: [])[:list]
    end

    def build_addresses_from_form_data
      address_list_params.to_a.map do |address_params|
        Address.from_json(address_params)
      end
    end
  end
end
