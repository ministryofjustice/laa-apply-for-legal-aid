module OfficeAddressHandling
private

  def one_line_office_address(office_address_struct)
    [
      office_address_struct.firm_name.downcase.titleize,
      office_address_struct.address_line_one.downcase.titleize,
      office_address_struct.address_line_two&.downcase&.titleize,
      office_address_struct.address_line_three&.downcase&.titleize,
      office_address_struct.address_line_four&.downcase&.titleize,
      office_address_struct.city.titleize,
      office_address_struct.post_code,
    ].compact.join(", ")
  end

  def office_address
    address = PDA::OfficeAddressRetriever.call(current_provider.selected_office.code)
    one_line_office_address(address)
  rescue PDA::OfficeAddressRetriever::NotFoundError
    I18n.t("errors.office_address.not_found")
  rescue PDA::OfficeAddressRetriever::ApiError
    I18n.t("errors.office_address.not_available")
  end
end
