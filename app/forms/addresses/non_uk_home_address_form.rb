module Addresses
  class NonUkHomeAddressForm < BaseForm
    form_for Address

    attr_accessor :country_name, :address_line_one, :address_line_two, :city, :county, :postcode

    validates :address_line_one, presence: true, unless: :draft?
    validate :validate_country_name, unless: :draft?

    def countries
      @countries ||= ::LegalFramework::NonUkHomeAddresses::All.call
    end

    def save
      model.update!(country_code: get_country_code) if valid?
      super
    end
    alias_method :save!, :save

    def validate_country_name
      errors.add(:country_name, I18n.t("activemodel.errors.models.address.attributes.country_name.invalid")) unless countries.map(&:description).include?(country_name)
    end

    def get_country_code
      return if country_name.blank?

      countries.find { |country| country.description == country_name }.code
    end
  end
end
