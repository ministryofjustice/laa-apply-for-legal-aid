module Addresses
  class NonUkHomeAddressForm < BaseForm
    form_for Address

    attr_accessor :country_code, :address_line_one, :address_line_two, :city, :county, :postcode

    validate :validate_country_code, unless: :draft?
    validates :address_line_one, presence: true, unless: :draft?

    def countries
      @countries ||= ::LegalFramework::NonUkHomeAddresses::All.call
    end

    def save
      model.update!(country_name: get_country_name) if valid?
      super
    end
    alias_method :save!, :save

    def validate_country_code
      errors.add(:country_code, I18n.t("activemodel.errors.models.address.attributes.country_name.invalid")) unless countries.map(&:code).include?(country_code)
    end

    def get_country_name
      return if country_code.blank?

      countries.find { |country| country.code == country_code }.description
    end
  end
end
