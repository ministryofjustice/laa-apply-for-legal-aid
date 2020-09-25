module Dashboard
  module SuspendableJob
    def job_suspended?
      Rails.configuration.x.suspended_dashboard_updater_jobs.include?(self.class.to_s)
    end
  end
end
