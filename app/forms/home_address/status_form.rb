module HomeAddress
  class StatusForm < BaseForm
    form_for Applicant

    attr_accessor :no_fixed_residence

    validates :no_fixed_residence, presence: true, unless: :draft?

    def save
      model.home_address = nil if no_fixed_residence.eql?("true")
      super
    end
    alias_method :save!, :save
  end
end
