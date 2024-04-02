module Addresses
  class NonUkHomeAddressForm < BaseForm
    form_for Address

    attr_accessor :country, :country_name, :address_line_one, :address_line_two, :city, :county, :postcode

    validates :address_line_one, presence: true, unless: :draft?
    validate :validate_country, unless: :draft?

    def countries
      @countries ||= ::LegalFramework::NonUkHomeAddresses::All.call
    end

    def save
      model.update!(country_name: get_country_name) if valid?
      super
    end
    alias_method :save!, :save

    def validate_country
      errors.add(:country, I18n.t("activemodel.errors.models.address.attributes.country.invalid")) unless countries.map(&:code).include?(country&.upcase)
    end

    def get_country_name
      return if country.blank?

      countries.find { |c| c.code == country }.description
    end
  end
end
