class PostSubmissionProcessingJob < ActiveJob::Base
  queue_as :default

  def perform(legal_aid_application_id)
    SubmissionConfirmationMailer.notify(legal_aid_application_id).deliver_later!
    @legal_aid_application = LegalAidApplication.find(legal_aid_application_id)
    reminder_mailings.each{ |mailing| mailing.cancel! }    
  end

  private

  def reminder_mailings
    @legal_aid_application.scheduled_mailings.where(mailer_klass: "SubmitApplicationReminderMailer")
  end
end
