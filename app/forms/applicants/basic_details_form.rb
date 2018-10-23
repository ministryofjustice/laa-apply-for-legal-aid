module Applicants
  class BasicDetailsForm < BaseForm
    form_for Applicant

    attr_accessor :first_name, :last_name
  end
end
