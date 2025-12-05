module CCMS
  class RestartSubmissions
    def initialize
      # get applications where state is submission_paused
      @applications = LegalAidApplication.joins(:state_machine).where(state_machine_proxies: { aasm_state: "submission_paused" }).order(:merits_submitted_at)
    end

    def self.call
      new.call
    end

    def call
      return "No paused submissions found" if @applications.empty?

      @applications.each(&:restart_submission!)
      "#{@applications.length} CCMS submissions restarted"
    end
  end
end
