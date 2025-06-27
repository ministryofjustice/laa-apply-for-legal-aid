module HomeAddress
  class StatusForm < BaseForm
    form_for Applicant

    attr_accessor :no_fixed_residence

    validates :no_fixed_residence, inclusion: ["true", "false", true, false], unless: :draft?

    def save
      model.home_address = nil if no_fixed_residence?
      super
    end
    alias_method :save!, :save

    # For task lists to be able to validate using form objects booleans must take both strings and boolean values into account
    def no_fixed_residence?
      no_fixed_residence.in?(["true", true])
    end
  end
end
