module Partners
  class DetailsForm < BaseForm
    include NationalInsuranceHandling
    include DateOfBirthHandling

    ATTRIBUTES = %i[first_name
                    last_name
                    has_national_insurance_number
                    national_insurance_number
                    date_of_birth_1i
                    date_of_birth_2i
                    date_of_birth_3i].freeze
    form_for Partner
    attr_accessor(*ATTRIBUTES)
    attr_writer :date_of_birth

    before_validation :normalise_national_insurance_number

    before_validation do
      squish_whitespaces(:first_name, :last_name)
    end

    # Note order of validation here determines order they appear on page
    # So validations for each field need to be in order, and presence validations
    # split so that they occur in the right order.
    validates :first_name, :last_name, presence: true, unless: :draft?

    validates :date_of_birth, presence: true, unless: :draft_and_not_partially_complete_date_of_birth?

    validates(
      :date_of_birth,
      date: {
        not_in_the_future: true,
        earliest_allowed_date: { date: "1900-01-01" },
      },
      allow_nil: true,
    )

    validates :has_national_insurance_number, inclusion: %w[true false], unless: :draft?
    validates :national_insurance_number, presence: true, if: :has_national_insurance_number?, unless: :draft?
    validate :validate_national_insurance_number
  end
end
