module Providers
  class NonUkCorrespondenceAddressesController < ProviderBaseController
    def show
      @form = Addresses::NonUkCorrespondenceAddressForm.new(model: non_uk_correspondence_address)
    end

    def update
      @form = Addresses::NonUkCorrespondenceAddressForm.new(form_params)
      render :show unless save_continue_or_draft(@form)
    end

  private

    def non_uk_correspondence_address
      applicant.address || applicant.build_address(location: "correspondence")
    end

    def form_params
      merge_with_model(non_uk_correspondence_address) do
        params.require(:non_uk_correspondence_address).permit(
          :country, :address_line_one, :address_line_two, :city, :county
        )
      end
    end
  end
end
