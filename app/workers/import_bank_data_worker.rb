class ImportBankDataWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker
  sidekiq_options retry: false

  def perform(applicant_id, token, token_expires_at)
    command = TrueLayer::BankDataImportService.call(
      applicant: Applicant.find(applicant_id),
      token: token,
      token_expires_at: token_expires_at
    )
    store errors: command.errors.to_a.flatten.to_json unless command.success?
  end
end
