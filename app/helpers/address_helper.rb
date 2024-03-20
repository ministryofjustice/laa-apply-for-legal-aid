module AddressHelper
  def address_with_line_breaks(address)
    return unless address

    sanitize [address.address_line_one,
              address.address_line_two,
              address.city,
              address.county,
              address.pretty_postcode,
              address.country?].compact.compact_blank.join("<br>"), tags: %w[br]
  end

  def address_one_line(address)
    return unless address

    sanitize [address.address_line_one,
              address.address_line_two,
              address.city,
              address.county,
              address.pretty_postcode,
              address.country?].compact.compact_blank.join(", ")
  end
end
