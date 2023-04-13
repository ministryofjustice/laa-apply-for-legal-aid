module Addresses
  class AddressLookupForm < BaseAddressLookupForm
    form_for Address

    attr_accessor :applicant_id, :postcode
  end
end
