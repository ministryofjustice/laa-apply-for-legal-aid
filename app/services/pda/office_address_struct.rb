module PDA
  class OfficeAddressStruct
    attr_reader :code, :firm_name, :address_line_one, :address_line_two, :address_line_three, :address_line_four, :county, :city, :post_code

    def initialize(office_code, office_address_hash = {})
      @code = office_code
      @firm_name = office_address_hash.dig("firm", "firmName")
      @address_line_one = office_address_hash.dig("office", "addressLine1")
      @address_line_two = office_address_hash.dig("office", "addressLine2")
      @address_line_three = office_address_hash.dig("office", "addressLine3")
      @address_line_four = office_address_hash.dig("office", "addressLine4")
      @city = office_address_hash.dig("office", "city")
      @county = office_address_hash.dig("office", "county")
      @post_code = office_address_hash.dig("office", "postCode")
    end
  end
end
