module TaskStatus
  class Applicants < Base
    def call
      status = ValueObject.new

      status.in_progress!
      status.not_started! unless applicant
      status.completed! if completed?

      status
    end

  private

    delegate :applicant, to: :application
    delegate :lead_linked_application, to: :application

    def completed?
      forms.all?(&:valid?) &&
        validators.all?(&:valid?)
    end

    # simple forms can be instatiated and their validity checked
    def forms
      [
        applicant_form,
        previous_reference_form,
      ]
    end

    # models that have validation or "completion" logic across multiple forms will need careful consideration
    # to ensure we "check" we have all the data to consider them complete. e.g. addresses, linked applications.
    def validators
      [
        address_validator,
        linked_applications_validator,
      ]
    end

    def applicant_form
      @applicant_form ||= ::Applicants::BasicDetailsForm.new(model: applicant)
    end

    def previous_reference_form
      @previous_reference_form ||= ::Applicants::PreviousReferenceForm.new(model: applicant)
    end

    def address_validator
      @address_validator ||= Validators::Address.new(applicant)
    end

    def proceedings_validator
      @proceedings_validator ||= Validators::Proceedings.new(application)
    end

    def linked_applications_validator
      @linked_applications_validator ||= Validators::LinkedApplications.new(application)
    end
  end
end
