module Providers
  class AddressSelectionsController < BaseController
    include Providers::ApplicationDependable
    include Providers::Steppable

    def new; end

    def create
      @form = Applicants::AddressSelectionForm.new(form_params)

      if @form.save
        redirect_to next_step_url
      else
        @addresses = build_addresses_from_form_data
        render :new
      end
    end

    private

    def permitted_params
      params.require(:address_selection).permit(:address, :postcode)
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
