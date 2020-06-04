class CitizenCompleteProcessingJob < ActiveJob::Base
  queue_as :default

  def perform(legal_aid_application_id)
    # TODO: should we send an email to the provider to confirm client has completed means?
    @legal_aid_application = LegalAidApplication.find(legal_aid_application_id)
    reminder_mailings.each(&:cancel!)
  end

  private

  def reminder_mailings
    @legal_aid_application.scheduled_mailings.where(mailer_klass: 'SubmitApplicantFinancialReminderMailer')
  end
end
