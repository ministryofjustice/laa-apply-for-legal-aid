module Addresses
  class AddressSelectionForm
    include BaseForm

    form_for Address

    attr_accessor :addresses, :postcode, :address_line_one, :address_line_two, :city, :county, :lookup_id

    before_validation :deserialize_address

    validates :lookup_id, presence: true

    def initialize(*args)
      super
      attributes[:lookup_used] = true
    end

    private

    def deserialize_address
      return if lookup_id.blank?

      attributes[:address_line_one] = selected_address.address_line_one
      attributes[:address_line_two] = selected_address.address_line_two
      attributes[:city] = selected_address.city
      attributes[:county] = selected_address.county
      attributes[:lookup_id] = selected_address.lookup_id
    end

    def exclude_from_model
      %i[addresses]
    end

    def selected_address
      @selected_address ||= addresses.find { |address| address.lookup_id == lookup_id }
    end
  end
end
