module AddressHelper
  def address_with_line_breaks(address)
    return unless address

    sanitize [address.organisation&.titleize,
              "#{address.address_line_one} #{address.address_line_two}"&.titleize,
              address.city&.titleize,
              address.pretty_postcode].compact.reject(&:blank?).join('<br>'), tags: ['br']
  end
end
