module Addresses
  class PartnerAddressForm < BaseAddressForm
    form_for Partner

    attr_accessor :address_line_one, :address_line_two, :city, :county, :postcode, :lookup_postcode, :lookup_error
  end
end
