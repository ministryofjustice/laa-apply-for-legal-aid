class CitizenCompleteMeansJob < ApplicationJob
  queue_as :default

  def perform(legal_aid_application_id)
    @legal_aid_application = LegalAidApplication.find(legal_aid_application_id)
    reminder_mailings.each(&:cancel!)
    SubmitProviderReminderService.new(@legal_aid_application).send_email
  end

  private

  def reminder_mailings
    @legal_aid_application.scheduled_mailings.where(mailer_klass: 'SubmitCitizenFinancialReminderMailer')
  end
end
