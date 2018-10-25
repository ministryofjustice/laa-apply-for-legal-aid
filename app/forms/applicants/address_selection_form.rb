module Applicants
  class AddressSelectionForm
    include BaseForm

    form_for Address

    attr_accessor :applicant_id, :address, :postcode, :address_line_one, :address_line_two, :city

    before_validation :deserialize_address

    validates :address, presence: true

    private

    def applicant
      @applicant ||= Applicant.find(applicant_id)
    end

    def model
      @model ||= applicant.addresses.build
    end

    def deserialize_address
      return unless address.present?
      hash = JSON.parse(address)
      attributes[:address_line_one] = hash['address_line_one']
      attributes[:address_line_two] = hash['address_line_two']
      attributes[:city] = hash['city']
    end

    def exclude_from_model
      %i[address]
    end
  end
end
