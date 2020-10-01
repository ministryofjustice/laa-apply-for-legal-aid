module Dashboard
  class ApplicantEmailJob < ActiveJob::Base
    include SuspendableJob

    def perform(application)
      return if job_suspended?

      Dashboard::SingleObject::ApplicantEmail.new(application).run
    end
  end
end
