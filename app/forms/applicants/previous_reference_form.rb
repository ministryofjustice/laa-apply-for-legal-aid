module Applicants
  class PreviousReferenceForm < BaseForm
    form_for Applicant

    CCMS_REFERENCE_REGEXP = /\A[13][0-9]{11}\z/

    attr_accessor :applied_previously, :previous_reference

    before_validation :normalise_previous_reference

    validates :applied_previously, inclusion: [true, false, "true", "false"], unless: :draft?
    validates :previous_reference, presence: true, if: :applied_previously?, unless: :draft?
    validate :validate_previous_reference, unless: :draft?

  private

    # For task lists to be able to validate using form objects booleans must take both strings and boolean values into account
    def applied_previously?
      applied_previously.in?(["true", true])
    end

    def normalise_previous_reference
      attributes[:previous_reference] = nil unless applied_previously?
      return if previous_reference.blank?

      previous_reference.delete!(" ")
    end

    def validate_previous_reference
      return unless applied_previously?

      errors.add :previous_reference, :not_valid unless CCMS_REFERENCE_REGEXP.match?(previous_reference)
    end
  end
end
