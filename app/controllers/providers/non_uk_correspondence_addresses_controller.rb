module Providers
  class NonUkCorrespondenceAddressesController < ProviderBaseController
    def show
      @form = Addresses::NonUkCorrespondenceAddressForm.new(model: non_uk_correspondence_address)
    end

  private

    def non_uk_correspondence_address
      applicant.address || applicant.build_address(location: "correspondence")
    end
  end
end
