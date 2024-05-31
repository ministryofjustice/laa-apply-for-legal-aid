module HomeAddress
  class StatusForm < BaseForm
    form_for Applicant

    attr_accessor :no_fixed_residence

    validates :no_fixed_residence, presence: true, unless: :draft?
  end
end
