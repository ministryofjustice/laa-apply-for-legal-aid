module HomeAddress
  class DifferentAddressReasonForm < BaseForm
    form_for Applicant

    attr_accessor :no_fixed_residence

    validates :no_fixed_residence, presence: true, unless: :draft?

    def save
      if no_fixed_residence.eql?("true") && model.home_address
        model.home_address.destroy!
      end
      super
    end
    alias_method :save!, :save
  end
end
