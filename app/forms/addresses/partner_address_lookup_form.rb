module Addresses
  class PartnerAddressLookupForm < BaseAddressLookupForm
    form_for Partner

    attr_accessor :postcode
  end
end
