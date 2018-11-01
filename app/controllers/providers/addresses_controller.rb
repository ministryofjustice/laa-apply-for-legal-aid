module Providers
  class AddressesController < BaseController
    include Providers::ApplicantDependable
    include Providers::Steppable

    before_action :set_current_step

    def new
      @form = Applicants::AddressForm.new
    end

    def create
      @form = Applicants::AddressForm.new(form_params)

      if @form.save
        redirect_to action_for_next_step(options: { application: applicant.legal_aid_application })
      else
        @lookup_postcode = params[:address][:lookup_postcode]
        render :new
      end
    end

    private

    def address_params
      params.require(:address).permit(:address_line_one, :address_line_two, :city, :county, :postcode, :lookup_postcode)
    end

    def form_params
      address_params.merge(applicant_id: applicant.id)
    end

    def set_current_step
      @current_step = :address
    end
  end
end
