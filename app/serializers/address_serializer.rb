class AddressSerializer < ActiveModel::Serializer
  attributes :organisation, :address_line_one, :address_line_two, :city, :county, :postcode, :applicant_id
end
