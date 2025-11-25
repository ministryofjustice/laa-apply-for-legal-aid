module AddressHelper
  def address_with_line_breaks(address)
    return unless address

    sanitize [address.address_line_one,
              address.address_line_two,
              address.city,
              address.county,
              address.pretty_postcode,
              address.country_name?].compact.compact_blank.join("<br>"), tags: %w[br]
  end

  def address_one_line(address)
    return unless address

    sanitize [address.address_line_one,
              address.address_line_two,
              address.city,
              address.county,
              address.pretty_postcode,
              address.country_name?].compact.compact_blank.join(", ")
  end

  def office_address_one_line(office_address)
    return unless office_address

    [office_address.address_line_one,
     office_address.address_line_two,
     office_address.address_line_three,
     office_address.address_line_four,
     office_address.city,
     office_address.county,
     office_address.postcode].compact.compact_blank.join(", ")
  end
end
