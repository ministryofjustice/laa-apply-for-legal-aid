module Dashboard
  class ApplicantEmailJob < ApplicationJob
    include SuspendableJob

    APPLY_EMAIL_REGEX = /#{Rails.configuration.x.email_domain.suffix}/.freeze

    def perform(application)
      return if job_suspended?

      return if application.applicant.email.match?(APPLY_EMAIL_REGEX) && Rails.env.production?

      Dashboard::SingleObject::ApplicantEmail.new(application).run
    end
  end
end
