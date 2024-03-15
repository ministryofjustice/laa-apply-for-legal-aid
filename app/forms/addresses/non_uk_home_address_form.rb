module Addresses
  class NonUkHomeAddressForm < BaseForm
    form_for Address

    attr_accessor :country, :address_line_one, :address_line_two, :city, :county

    validates :country, :address_line_one, presence: true, unless: :draft?

    def countries
      @countries ||= ::LegalFramework::NonUkHomeAddresses::All.call
    end
  end
end
