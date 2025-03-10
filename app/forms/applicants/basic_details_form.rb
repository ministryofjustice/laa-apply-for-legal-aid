module Applicants
  class BasicDetailsForm < BaseForm
    include DateOfBirthHandling

    ATTRIBUTES = %i[first_name
                    last_name
                    date_of_birth_1i
                    date_of_birth_2i
                    date_of_birth_3i
                    changed_last_name
                    last_name_at_birth].freeze

    form_for Applicant

    attr_accessor(*ATTRIBUTES)
    attr_writer :date_of_birth

    before_validation do
      squish_whitespaces(:first_name, :last_name, :last_name_at_birth)
    end

    # Note order of validation here determines order they appear on page
    # So validations for each field need to be in order, and presence validations
    # split so that they occur in the right order.
    validates :first_name, presence: true, unless: proc { draft? && last_name.present? }
    validates :last_name, presence: true, unless: proc { draft? && first_name.present? }
    validates :date_of_birth, presence: true, unless: :draft_and_not_partially_complete_date_of_birth?
    validates :changed_last_name, inclusion: [true, false, "true", "false"], unless: :draft?
    validates :last_name_at_birth, presence: true, unless: proc { draft? || changed_last_name.to_s != "true" }

    validates(
      :date_of_birth,
      date: {
        not_in_the_future: true,
        earliest_allowed_date: { date: "1900-01-01" },
      },
      allow_nil: true,
    )

    def save
      if changed_last_name.to_s == "false"
        attributes[:last_name_at_birth] = nil
      end
      super
    end
    alias_method :save!, :save
  end
end
