module Addresses
  class AddressSelectionForm < BaseAddressSelectionForm
    form_for Address

    EDIT_DETAILS = EditStruct.new(section: :client_case_details, task: :client_details, application_path: "legal_aid_application")

    attr_accessor :addresses, :postcode, :address_line_one, :address_line_two, :city, :county, :lookup_id, :location
  end
end
