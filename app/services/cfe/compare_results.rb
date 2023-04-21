module CFE
  class CompareResults
    def self.call
      new.call
    end

    def call
      legal_aid_applications.each do |legal_aid_application|
        compare_values_for legal_aid_application
      end
      Setting.setting.update!(cfe_compare_run_at: run_time)
    end

  private

    def compare_values_for(legal_aid_application)
      v6 = CFECivil::SubmissionBuilder.call(legal_aid_application, save_result: false)
      CFE::CompareSubmission.call(legal_aid_application, v6)
    end

    def legal_aid_applications
      @legal_aid_applications ||= cfe_submissions.map(&:legal_aid_application)
    end

    def cfe_submissions
      @cfe_submissions ||= CFE::Submission.where(created_at: last_run..run_time)
    end

    def run_time
      @run_time ||= Time.zone.now
    end

    def last_run
      # get the last run time or, if it's missing, run for the last 24 hours,
      @last_run ||= (Setting.setting.cfe_compare_run_at || 24.hours.ago)
    end
  end
end
