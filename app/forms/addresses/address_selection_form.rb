module Addresses
  class AddressSelectionForm < BaseAddressSelectionForm
    form_for Address

    attr_accessor :addresses, :postcode, :address_line_one, :address_line_two, :city, :county, :lookup_id
  end
end
