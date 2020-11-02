module Applicants
  class EmployedForm
    include BaseForm

    form_for Applicant

    attr_accessor :employed

    validates :employed, presence: true
  end
end
