class AddressJsonBuilder < BaseJsonBuilder
  def as_json
    {
      id:,
      address_line_one:,
      address_line_two:,
      city:,
      county:,
      postcode:,
      applicant_id:,
      created_at:,
      updated_at:,
      organisation:,
      lookup_used:,
      lookup_id:,
      building_number_name:,
      location:,
      country_code:,
      country_name:,
      care_of:,
      care_of_first_name:,
      care_of_last_name:,
      care_of_organisation_name:,
      address_line_three:,
    }
  end
end
