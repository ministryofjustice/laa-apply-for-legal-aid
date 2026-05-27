module Addresses
  class AddressLookupForm < BaseAddressLookupForm
    form_for Address

    EDIT_DETAILS = EditStruct.new(section: :client_case_details, task: :client_details, application_path: "legal_aid_application")

    attr_accessor :applicant_id, :postcode, :building_number_name, :location
  end
end
