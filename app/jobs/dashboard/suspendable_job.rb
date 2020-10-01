module Dashboard
  module SuspendableJob
    def job_suspended?
      suspended_jobs.include?(self.class.to_s)
    end

    def suspended_jobs
      Rails.configuration.x.suspended_geckoboard_updater_jobs[HostEnv.environment]
    end
  end
end
