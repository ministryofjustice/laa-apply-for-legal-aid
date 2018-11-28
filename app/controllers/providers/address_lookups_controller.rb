module Providers
  class AddressLookupsController < BaseController
    include Providers::ApplicationDependable
    include Steppable

    def show
      @form = Applicants::AddressLookupForm.new
    end

    def update
      @form = Applicants::AddressLookupForm.new(form_params)
      @back_step_url = providers_legal_aid_application_address_lookup_path

      if @form.save
        redirect_to next_step_url
      else
        render :show
      end
    end

    private

    def form_params
      params.require(:address_lookup).permit(:postcode).merge(applicant_id: applicant.id)
    end
  end
end
