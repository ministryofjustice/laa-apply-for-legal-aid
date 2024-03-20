module HomeAddress
  class DifferentAddressForm < BaseForm
    form_for Applicant

    attr_accessor :same_correspondence_and_home_address

    validates :same_correspondence_and_home_address, presence: true, unless: :draft?

    def save
      if same_correspondence_and_home_address.eql?("true") && model.home_address
        model.home_address.destroy!
      end
      super
    end
    alias_method :save!, :save
  end
end
