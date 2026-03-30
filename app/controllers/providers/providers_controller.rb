module Providers
  class ProvidersController < ProviderBaseController
    legal_aid_application_not_required!

    def show
      @provider = current_provider
      @office_address = office_address if @provider.selected_office.present?
      @ccms_user_details = ccms_user["ccmsUserDetails"]
    end

  private

    def office_address
      address = PDA::OfficeAddressRetriever.call(@provider.selected_office.code)

      [
        address.firm_name.downcase.titleize,
        address.address_line_one.downcase.titleize,
        address.address_line_two&.downcase&.titleize,
        address.address_line_three&.downcase&.titleize,
        address.address_line_four&.downcase&.titleize,
        address.city.titleize,
        address.post_code,
      ].compact.join(", ")
    rescue PDA::OfficeAddressRetriever::NotFoundError
      I18n.t("providers.providers.show.office_address_not_found")
    rescue PDA::OfficeAddressRetriever::ApiError
      I18n.t("providers.providers.show.office_address_not_available")
    end

    def ccms_user
      @ccms_user = CCMSUser::UserDetails.call(@provider.silas_id)
    rescue CCMSUser::UserDetails::UserNotFound
      @ccms_user = { ccmsUserDetails: { userName: "Not found", userPartyId: "Not found" } }.with_indifferent_access
    end
  end
end
