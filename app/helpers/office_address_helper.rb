module OfficeAddressHelper
  def office_address_one_line(address)
    [
      address.firm_name.downcase.titleize,
      address.address_line_one.downcase.titleize,
      address.address_line_two&.downcase&.titleize,
      address.address_line_three&.downcase&.titleize,
      address.address_line_four&.downcase&.titleize,
      address.city.titleize,
      address.post_code,
    ].compact.join(", ")
  end
end
