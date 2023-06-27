module Partners
  class FullEmploymentDetailsForm < BaseForm
    form_for Partner

    attr_accessor :full_employment_details

    validates :full_employment_details, presence: true, unless: :draft?
  end
end
