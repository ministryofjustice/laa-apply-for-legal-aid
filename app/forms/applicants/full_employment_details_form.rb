module Applicants
  class FullEmploymentDetailsForm < BaseForm
    form_for Applicant

    attr_accessor :full_employment_details

    validates :full_employment_details, presence: true, unless: :draft?
  end
end
