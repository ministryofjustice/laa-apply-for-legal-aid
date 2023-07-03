module CFE
  class CompareResults
    # NOTE: This is intended as a temporary class while we switch from CFE-Legacy to CFE-Civil
    # Once that change over is complete, the aim is that this can be removed, along with
    def self.call
      new.call
    end

    def call
      ResetGoogleSheetFilter.call
      legal_aid_applications.each do |legal_aid_application|
        compare_values_for legal_aid_application
      end
      Setting.setting.update!(cfe_compare_run_at: run_time)
    end

  private

    def compare_values_for(legal_aid_application)
      v6 = CFECivil::SubmissionBuilder.new(legal_aid_application)
      v6.call
      CFE::CompareSubmission.call(legal_aid_application, v6)
    end

    def legal_aid_applications
      @legal_aid_applications ||= cfe_submissions.map(&:legal_aid_application).uniq
    end

    def cfe_submissions
      @cfe_submissions ||= CFE::Submission.where(created_at: last_run..run_time, aasm_state: "results_obtained")
    end

    def run_time
      @run_time ||= Time.current
    end

    def last_run
      # get the last run time or, if it's missing, run for the last 24 hours,
      @last_run ||= (Setting.setting.cfe_compare_run_at || 24.hours.ago)
    end
  end
end
