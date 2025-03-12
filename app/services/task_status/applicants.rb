module TaskStatus
  class Applicants < Base
    def call
      return Task::Status::NOT_STARTED unless applicant
      return Task::Status::IN_PROGRESS if applicant.addresses.blank?
      return Task::Status::COMPLETED if completed?

      Task::Status::IN_PROGRESS
    end

  private

    delegate :applicant, to: :application

    def completed?
      forms.all?(&:valid?)
    end

    def forms
      [
        applicant_form,
        previous_reference_form,
      ]
    end

    def applicant_form
      ::Applicants::BasicDetailsForm.new(model: applicant)
    end

    def previous_reference_form
      ::Applicants::PreviousReferenceForm.new(model: applicant)
    end

    def link_application_form
      # TODO: this needs to consider multiple interdependant forms
    end
  end
end
