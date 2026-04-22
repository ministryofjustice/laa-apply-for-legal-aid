module Providers
  class ProvidersController < ProviderBaseController
    include OfficeAddressHandling

    legal_aid_application_not_required!

    def show
      @provider = current_provider
      @office_address = office_address if @provider.selected_office.present?
      @ccms_user_details = ccms_user["ccmsUserDetails"]
    end

  private

    def ccms_user
      @ccms_user = CCMSUser::UserDetails.call(@provider.silas_id)
    rescue CCMSUser::UserDetails::UserNotFound
      @ccms_user = { ccmsUserDetails: { userName: "Not found", userPartyId: "Not found" } }.with_indifferent_access
    end
  end
end
