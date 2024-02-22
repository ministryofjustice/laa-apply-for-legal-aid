module Addresses
  class NonUkCorrespondenceAddressForm < BaseForm
    form_for Address

    attr_accessor :country, :address_line_one, :address_line_two, :city, :county

    validates :country, :address_line_one, presence: true, unless: :draft?
  end
end
