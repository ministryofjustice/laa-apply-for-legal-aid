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

      if @form.save
        redirect_to next_step_url
      else
        render :new
      end
    end

    private

    def form_params
      params.require(:address_lookup).permit(:postcode).merge(applicant_id: applicant.id)
    end
  end
end
