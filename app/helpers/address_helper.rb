module AddressHelper
  def address_with_line_breaks(address)
    return unless address
    sanitize [address.organisation,
              address.address_line_one,
              address.address_line_two,
              address.city,
              address.postcode].compact.reject(&:blank?).join('<br>'), tags: ['br']
  end
end
