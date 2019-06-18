module LegalAidApplications
  class SubstantiveApplicationForm
    include BaseForm
    form_for LegalAidApplication
    
    after_validation :substantive_application_deadline_on

    attr_accessor :substantive_application

    validates :substantive_application, presence: { unless: :draft? }

    def substantive_application_deadline_on
      return model.substantive_application_deadline_on if model.substantive_application_deadline_on?

      attributes['substantive_application_deadline_on'] ||= substantive_application_deadline
    end

    private

    def substantive_application_deadline
      WorkingDayCalculator.working_days_from_now(working_days_to_complete)
    end

    def working_days_to_complete
      LegalAidApplication::WORKING_DAYS_TO_COMPLETE_SUBSTANTIVE_APPLICATION
    end
  end
end
