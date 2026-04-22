module OfficeAddressHandling
private

  def office_address
    address = PDA::OfficeAddressRetriever.call(current_provider.selected_office.code)

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
    I18n.t("errors.office_address.not_found")
  rescue PDA::OfficeAddressRetriever::ApiError
    I18n.t("errors.office_address.not_available")
  end
end
