module Applicants
  class AddressForm
    include BaseForm

    form_for Address

    attr_accessor :applicant_id, :address_line_one, :address_line_two, :city, :county, :postcode, :lookup_postcode, :lookup_error

    before_validation :normalise_postcode

    validate :validate_building_and_street

    validates :city, :postcode,
              presence: true

    validates :postcode, format: { with: POSTCODE_REGEXP, if: proc { |a| a.postcode.present? } }

    def exclude_from_model
      %i[lookup_postcode lookup_error]
    end

    private

    def applicant
      @applicant ||= Applicant.find(applicant_id)
    end

    def model
      @model ||= applicant.addresses.build
    end

    def normalise_postcode
      return unless postcode.present?
      postcode.delete!(' ')
      postcode.upcase!
    end

    def validate_building_and_street
      return if address_line_one.present? || address_line_two.present?
      errors.add(:address_line_one, :blank)
    end
  end
end
