module TaskStatus
  class CheckProviderAnswers < Base
    def call
      status = ValueObject.new

      # intialise task status of all tasks in section and check if they are all complete.
      # if so then this task can be started.
      #
      status.cannot_start!
      status.not_started! if section_statuses.all?(&:completed?)

      # status.in_progress? if in_progress?
      status.completed! if completed?

      status
    end

  private

    # § TODO: to determine the status of a CYA page and whether it is in progress or complete we may need to track/store
    # state changes and then use that data to determine the status of this CYA task.
    #
    # TODO: state changed to something beyond "checking_applicant_details", or state has ever been "applicant_details_checked"
    # or page history includes the page url
    def completed?
      application.checking_applicant_details?
    end

    # TODO: § could check if state has ever been "checking_applicant_details" but not "applicant_details_checked"
    def in_progress?
      false
    end

    def section_statuses
      [
        Applicants.new(application).call,
        ProceedingsTypes.new(application).call,
        HasNationalInsuranceNumbers.new(application).call,
      ]
    end
  end
end
