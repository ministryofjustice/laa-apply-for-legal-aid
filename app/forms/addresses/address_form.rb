module Addresses
  class AddressForm
    include BaseForm

    form_for Address

    attr_accessor :address_line_one, :address_line_two, :city, :county, :postcode, :lookup_postcode, :lookup_error

    before_validation :normalise_postcode

    validate :validate_building_and_street

    validates :city, :postcode,
              presence: true,
              unless: :draft?

    validates :postcode, format: { with: POSTCODE_REGEXP, allow_blank: true }

    def exclude_from_model
      %i[lookup_postcode lookup_error]
    end

    def initialize(*args)
      super
      attributes[:lookup_used] = lookup_postcode.present?
    end

    private

    def normalise_postcode
      return if postcode.blank?

      postcode.delete!(' ')
      postcode.upcase!
    end

    def validate_building_and_street
      return if draft? || address_line_one.present? || address_line_two.present?

      errors.add(:address_line_one, :blank)
    end
  end
end
