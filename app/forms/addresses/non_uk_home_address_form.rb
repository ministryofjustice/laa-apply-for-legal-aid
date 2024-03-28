module Addresses
  class NonUkHomeAddressForm < BaseForm
    form_for Address

    attr_accessor :country, :address_line_one, :address_line_two, :city, :county, :postcode

    validates :address_line_one, presence: true, unless: :draft?
    validate :validate_country, unless: :draft?

    def countries
      @countries ||= ::LegalFramework::NonUkHomeAddresses::All.call
    end

    def validate_country
      errors.add(:country, I18n.t("activemodel.errors.models.address.attributes.country.invalid")) unless countries.map(&:code).include?(country&.upcase)
    end
  end
end
