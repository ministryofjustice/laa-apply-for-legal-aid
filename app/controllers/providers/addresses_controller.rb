module Providers
  class AddressesController < BaseController
    include Providers::ApplicationDependable
    include Providers::Steppable

    def show
      @form = Applicants::AddressForm.new(current_address_params)
    end

    def update
      @form = Applicants::AddressForm.new(form_params)

      if @form.save
        redirect_to next_step_url
      else
        render :show
      end
    end

    private

    def address_attributes
      %i[address_line_one address_line_two city county postcode lookup_postcode lookup_error]
    end

    def current_address_params
      return unless applicant.address

      applicant.address.attributes.symbolize_keys.slice(*address_attributes)
    end

    def address_params
      params.require(:address).permit(*address_attributes)
    end

    def form_params
      address_params.merge(applicant_id: applicant.id)
    end
  end
end
