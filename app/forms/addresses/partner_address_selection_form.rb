module Addresses
  class PartnerAddressSelectionForm < BaseAddressSelectionForm
    form_for Partner

    attr_accessor :addresses, :postcode, :address_line_one, :address_line_two, :city, :county, :lookup_id
  end
end
