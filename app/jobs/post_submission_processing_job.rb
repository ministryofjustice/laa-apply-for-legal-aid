class PostSubmissionProcessingJob < ApplicationJob
  queue_as :default

  def perform(legal_aid_application_id, feedback_url)
    legal_aid_application = LegalAidApplication.find(legal_aid_application_id)
    ScheduledMailing.send_now!(mailer_klass: SubmissionConfirmationMailer,
                               mailer_method: :notify,
                               legal_aid_application_id: legal_aid_application_id,
                               addressee: legal_aid_application.provider.email,
                               arguments: [legal_aid_application_id, feedback_url])
  end
end
