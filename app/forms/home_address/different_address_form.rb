module HomeAddress
  class DifferentAddressForm < BaseForm
    form_for Applicant

    attr_accessor :different_home_address

    validates :different_home_address, presence: true, unless: :draft?
  end
end
