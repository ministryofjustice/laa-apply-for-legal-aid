module Applicants
  class EmployedForm < NewBaseForm

    form_for Applicant

    attr_accessor :employed

    validates :employed, presence: true
  end
end
