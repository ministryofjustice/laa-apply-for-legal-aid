module Providers
  class ProvidersController < ProviderBaseController
    legal_aid_application_not_required!

    def show
      @provider = current_provider
      @ccms_user_details = ccms_user["ccmsUserDetails"]
    end

  private

    def ccms_user
      @ccms_user = CCMSUser::UserDetails::Silas.call(@provider.silas_id)
    rescue CCMSUser::UserDetails::Silas::UserNotFound
      @ccms_user = { ccmsUserDetails: { userName: "Not found", userPartyId: "Not found" } }.with_indifferent_access
    end
  end
end
