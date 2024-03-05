module HomeAddress
  class DifferentAddressForm < BaseForm
    form_for Applicant

    attr_accessor :same_correspondence_and_home_address

    validates :same_correspondence_and_home_address, presence: true, unless: :draft?
  end
end
